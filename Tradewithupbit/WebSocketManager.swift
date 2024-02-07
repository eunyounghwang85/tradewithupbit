//
//  WebSocketManager.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation
import UIKit
import Starscream

class WebSocketManager : NSObject {
    
    static let shared: WebSocketManager = {
        return WebSocketManager()
    }()
  
    lazy var barrierQueue = DispatchQueue(label: MAINSIGN.appending(".heyWebSocket.Barrier.DispatchQueue"), attributes: .concurrent)
    lazy var keyint:NSInteger = 0
    // quemanager
    lazy var runningOperations:[Operation] = [Operation]()
    // add objever 여부 확인
    lazy var appobjever : Bool = false
    lazy var appLoadToWait: Bool = false
    
    lazy var state : WebSocketSessionState = .closed
    lazy var reconnectTimer:ReconnectTimer? = nil
    lazy var foregroundReconnection : ForegroundReconnection? = nil
    lazy var webSocketQueue : OperationQueue  = {
        let  _webSocketQueue = OperationQueue()
        _webSocketQueue.name = MAINSIGN.appending(".heyWebSocket.OperationQueue")
        _webSocketQueue.maxConcurrentOperationCount = 4
        return _webSocketQueue
    }()
    lazy var socket : WebSocket? = nil {
            
        willSet{
            guard let old = socket else {
                return
            }
            old.disconnect()
        }
        didSet{
            guard let s = socket else {
                return
            }
            s.callbackQueue = self.barrierQueue
            s.delegate = self
            s.connect()
        }
    }
  
    override init() {
        super.init()
    
    }
    
    deinit {
        self.closeSocket(true)
        self.cancelAlloperation()
        NotificationCenter.default.removeObserver(self)
    }
    func commitIntial(_ start:Bool = false){
        
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
            self.socket =  WebSocket(request: request)
        }
        self.reconnectTimer = ReconnectTimer(RECONNECT_TIMER, RECONNECT_TIMER_MAX_DEFAULT){
            [weak self] in
            guard let self =  self else{
                return
            }
            self.reconnect()
        }
        self.foregroundReconnection = ForegroundReconnection(sessionManager: self)
    
    }
    func reconnect(){
        self.updateState(.starting)
        self.connectToInternal()
    }
    func triggerDelayedReconnect(){
        self.reconnectTimer?.schedule()
    }
    func connectToInternal(){
        guard let socket = self.socket, self.state == .starting else {
            return
        }
        self.updateState(.connecting)
        socket.connect()
    }

    func openSocket(){
        guard socket != nil  else {
            self.commitIntial(true)
            return
        }
        
        guard self.state != .connected else {
            return
        }
        self.reconnectTimer?.resetRetryInterval()
        self.reconnect()
    }
    func closeSocket(_ isforce:Bool=false) {
        guard let socket = self.socket else {
            return
        }
        
        defer {
            self.reconnectTimer?.stop()
        }
        self.updateState(.closing)
        guard isforce else {
            
            socket.disconnect()
            
            return
        }
        socket.forceDisconnect()
        self.socket = nil
       
    }
    func cancelAlloperation() {
        
        
        synchronized(self){ [weak self] in
             guard let self = self  else {
                 return
             }
            _ = self.runningOperations.map{$0.cancel()}
            self.runningOperations.removeAll()
            self.webSocketQueue.cancelAllOperations()
        }
      
    }
    
    func updateState(_ newState:WebSocketSessionState) {
        if case WebSocketSessionState.error(let e) = newState {
            Log("\(e?.localizedDescription ?? "error empty")")
        }
        state = newState
    }
}
extension WebSocketManager   {
    var requiresTearDown : Bool {
        return self.state != .closed && self.state != .starting
    }
}
extension WebSocketManager  :  WebSocketDelegate {
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
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            self.updateState(.connected)
            self.reconnectTimer?.resetRetryInterval()
            Log("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            
            Log("websocket is disconnected: \(reason) with code: \(code)")
            if self.state != .closing {
                // 앱에서 disconnect 한게 아니면~
                self.triggerDelayedReconnect()
            }
            self.updateState(.closed)
        case .text(let string):
            Log("Received text: \(string)")
            
        case .binary(let data):
            Log("Received data: \(data.count)")
            let str = String(decoding: data, as: UTF8.self)
            Log(str)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
             self.updateState(.closed)
        case .error(let error):
            Log(String(describing: error))
            self.updateState(.error(error))
            //handleError(error)
        case .peerClosed:
                   break
        }
    }
    
}


