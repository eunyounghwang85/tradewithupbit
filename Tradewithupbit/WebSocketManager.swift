//
//  WebSocketManager.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation
import UIKit
import Starscream
import Combine

enum initalError: Error {
    case none
}
class WebSocketManager : NSObject {
    
    static let shared: WebSocketManager = {
        return WebSocketManager()
    }()
  
   
    lazy var keyint:NSInteger = 0

    // add objever 여부 확인
    lazy var appobjever : Bool = false
    lazy var appLoadToWait: Bool = false
    
    lazy var reconnectTimer:ReconnectTimer? = nil {
        willSet{
            guard let reconnectTimer = reconnectTimer else {
                return
            }
            reconnectTimer.stop()
        }
    }
    var foregroundReconnection : ForegroundReconnection!
    
    lazy var state : WebSocketSessionState = .closed
    // error 만관리 할것이므로 예외처리 없음 Never
    lazy var error: CurrentValueSubject<Error, Never> = CurrentValueSubject<Error, Never>(initalError.none)

    
    
    var cancelBag: Set<AnyCancellable> = []
    
    lazy var barrier:Int = 1
    
    lazy var socket : WebSocket? = nil {
            
        willSet{
            guard let old = socket  else {
                return
            }
            //old.callbackQueue = DispatchQueue.main
            //old.delegate = nil
            old.forceDisconnect()
        }
        
        didSet{
            guard let s = socket else {
                return
            }
           // let barrierQueue = DispatchQueue(label: MAINSIGN.appending(".heyWebSocket.Barrier.\(barrier).DispatchQueue"), attributes:.concurrent)
           // barrier += 1
            
           // s.callbackQueue = barrierQueue
            self.onEventRecive(s)
         
        }
    }
  
    override init() {
        super.init()
        foregroundReconnection = ForegroundReconnection(sessionManager: self)
        self.errorManager()
 
    }
    
    deinit {
        self.closeSocket(true)
        NotificationCenter.default.removeObserver(self)
    }
    func commitInitial(_ start:Bool = false){
        
        defer {
            if start {
                openSocket()
            }
        }
        
        guard  socket == nil  else {
            return
        }
        
        self.updateState(.starting)
        var request = URLRequest(url: URL(string: "wss://api.upbit.com/websocket/v1")!)
        request.timeoutInterval = 60
        
        if isauthorizationToken {
            request.allHTTPHeaderFields = AuthorizationHeader()
            //let compression = WSCompression()
            self.socket =  WebSocket(request: request, useCustomEngine: true)
        }else{
            self.socket =  WebSocket(request: request, useCustomEngine: false)
        }
     
        self.reconnectTimer =  ReconnectTimer(RECONNECT_TIMER, RECONNECT_TIMER_MAX_DEFAULT)
       
    }
    
    func reconnect(){
    
        self.updateState(.starting)
        self.connectToInternal()
    }
    func triggerDelayedReconnect(){
        
        guard self.foregroundReconnection.appState == .applicationDidBecome, let r = self.reconnectTimer else {
            return
        }
        
        r.schedule {
            [weak self] in
            guard let self =  self else{
                return
            }
            Log("reconnect call!!")
            guard self.foregroundReconnection.appState == .applicationDidBecome, !self.state.tryConnected else {
                return
            }
            Log("reconnect start!!")
            self.reconnect()
        }
    }
    func connectToInternal(){
        
        guard self.foregroundReconnection.appState == .applicationDidBecome,
              let socket = self.socket, self.state == .starting else {
            return
        }
      
        self.updateState(.connecting)
        socket.connect()
    }

    func openSocket(){
        guard socket != nil  else {
            self.commitInitial(true)
            return
        }
        
        guard self.foregroundReconnection.appState == .applicationDidBecome, !self.state.tryConnected else {
            return
        }
        self.error.send(initalError.none)
        self.reconnectTimer?.stop()
        self.reconnectTimer?.resetRetryInterval()
        self.reconnect()
    }
    func closeSocket(_ isforce:Bool=false) {
        
        guard let socket = self.socket  else {
            return
        }
        
        self.reconnectTimer?.stop()
        defer{
            if isforce {
                self.socket = nil
            }
        }
        let current = self.state
        guard !current.tryClose else {
            return
        }
        
        Log("websocket is Closing \(String(describing: current))")
        self.updateState(.closing)
        guard current.tryConnected else {
            return
        }
        
        if isforce {
            socket.forceDisconnect()
        }else {
            socket.disconnect()
        }

      
    }
   
    func errorManager() {
        
  
        self.error.sink {
            _ in
            // Log("complite: \(c)")
            
        } receiveValue: { [weak self] e in
            
            guard let self else { return }
            Task { @MainActor in
                
                guard (e as? initalError) == nil else {
                    // connecting 호출전 connected 하고 나서
                    return
                }
                
                Log("websocket recived error:\n \(String(describing: e) )")
               
                guard  self.isExpiredAccesstoken(e)  else {
                   
                    guard !self.state.tryClose  else {
                        return
                    }
                    
                    self.updateState(.closed)
                    self.triggerDelayedReconnect()
                 
                   return
                }
              
                self.reInitialwhenfired()
                
            }
       
        }.store(in: &cancelBag)
        
    }
    func updateState(_ newState:WebSocketSessionState) {
       
        guard case WebSocketSessionState.error(let e) = newState else {
            Log("updateState:\(newState)")
            // error는 반영하지 않음
            self.state = newState
            return
        }
        
        
       
    
        // error 발생할경우 소켓클로즈 처리
        
        
       /* defer {
            if let proto = e as? WSError , proto.type == .protocolError {
                Log("아무것도 하지 않는다")
                self.updateState(.closed)
                
            }else if self.state == .starting {
                self.triggerDelayedReconnect()
            }else if !self.state.tryClose {
                self.updateState(.closed)
                self.triggerDelayedReconnect()
            }
        }*/
        // MARK: HTTPUpgradeError 반환 받을시 무조건 엔진 이니셜 갱신 해야 connected됨
        guard  let authError = e as? HTTPUpgradeError, isExpiredAccesstoken(authError)  else {
            
            guard !self.state.tryClose  else {
                return
            }
            self.updateState(.closed)
            
            guard let proto = e as? WSError , proto.type == .protocolError else {
                self.triggerDelayedReconnect()
                return
            }
            Log("아무것도 하지 않는다")
           
            return
        }
        /*guard (e as? HTTPUpgradeError) != nil else {
            return
        }*/
        
        let currentRetryInterval = reconnectTimer?.currentRetryInterval ?? RECONNECT_TIMER
        self.reconnectTimer?.stop()
        self.updateState(.closed)
        self.socket = nil
        // accesstoken 재발급
        self.commitInitial()
        self.reconnectTimer?.currentRetryInterval = currentRetryInterval
        self.triggerDelayedReconnect()
    }
}
extension WebSocketManager   {
    var requiresTearDown : Bool {
        return self.state.requiresTearDown
    }

}
extension WebSocketManager   {
    func reInitialwhenfired(){
        guard self.state != .starting && !(self.reconnectTimer?.timer?.isValid ?? false) else {
            Log("retry호출 기다려준다")
            return
        }
        let currentRetryInterval = self.reconnectTimer?.currentRetryInterval ?? RECONNECT_TIMER
        Log("HTTPUpgradeError start new initail \(currentRetryInterval)")
        self.updateState(.closed)
        self.closeSocket(true)
        self.commitInitial()
        self.reconnectTimer?.currentRetryInterval = currentRetryInterval
        self.triggerDelayedReconnect()
    }
    func isExpiredAccesstoken<T> (_ error:T) -> Bool {
        
        if let error  = error as? HTTPUpgradeError, case .notAnUpgrade(_, _) = error {
            return true
            /*
            switch error {
            case .notAnUpgrade(let ercode, _):
                // expiredAccesstoken == 401
                // ercode == 401
                // notAnUpgrade(429
                return ercode == 401 || ercode == 429
            case .invalidData:
                return false
            }*/
            
        }else if let error  = error as? WSError {
            return error.type == .protocolError && error.code == 1002
        }
        return false
        
      
    }
    
    func sendMesseage(){
        guard self.state == .connected, let socket = self.socket else {
            return
        }
        var obje = marketParam(type: .ticker)
        if isauthorizationToken {
            // 전체시세 빈배열
            obje.codes = ["KRW-BTC"]
        }else{
            // codes 필수로 1개이상
            obje.codes = ["KRW-BTC"]
            
        }
       
        let stt = sendFormesseage(market: [obje])
        Log("<<didReceive>> " + stt)
        socket.write(string:stt, completion:nil)
    }
    
    func onEventRecive(_ socket:WebSocket) {
        socket.onEvent = {
           [weak self] event  in
            guard let self = self else {return}
            
            switch event {
            case .connected(let headers):
                self.error.send(initalError.none)
                self.updateState(.connected)
                self.reconnectTimer?.resetRetryInterval()
                Log("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                
                Log("websocket is disconnected: \(reason) with code: \(code)")
                let current = self.state
                self.updateState(.closed)
                if current != .closing {
                    // 앱에서 disconnect 한게 아니면~
                    self.triggerDelayedReconnect()
                }
                break
            case .text(let string):
                Log("Received text: \(string)")
                break
            case .binary(let data):
                Log("Received data: \(data.count)")
                let str = String(decoding: data, as: UTF8.self)
                Log(str)
                break
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(let m):
                Log("websocket is reconnectSuggested:\(m)")
                break
            case .cancelled:
                Log("websocket is cancelled")
                
                guard (self.error.value as? initalError) != nil, !self.state.tryClose else {
                    return
                }
                self.updateState(.closed)
                self.triggerDelayedReconnect()
               
                break
            case .peerClosed:
                Log("websocket is peerClosed")
                
                guard (self.error.value as? initalError) != nil, !self.state.tryClose else {
                    return
                }
                self.reInitialwhenfired()
                break
            case .error(let error):
                if let e = error {
                   
                    self.error.send(e)
                   /* if let prto = e as? WSError {
                        self.error.send(prto)
                    }else if let proto = e as? HTTPUpgradeError {
                        self.error.send(proto)
                    }else{
                        self.error.send(e)
                    }*/
                    /*guard let proto = e as? WSError , proto.type == .protocolError else {
                        self.error.send(e)
                        return
                    }
                    self.error.send(e)
                    self.error.send(completion: .failure(proto.type))
                  */
                }else{
                    Log("websocket is error:- error empty")
                
                }
               // self.updateState(.error(error))
                break
            }
            
        }
    }
    
   
}


