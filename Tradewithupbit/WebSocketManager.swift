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
    /// connet 관리
    lazy var isConnected = false
    
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
       
        // addobserver
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name:  UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification(_:)), name:  UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateNotification(_:)), name:  UIApplication.willTerminateNotification, object: nil)
        
      
    }
    
    deinit {
        self.closeSocket(true)
        self.cancelAlloperation()
        NotificationCenter.default.removeObserver(self)
    }
    func commitIntial(){
        guard let socket = self.socket else {
            var request = URLRequest(url: URL(string: "wss://api.upbit.com/websocket/v1")!)
            request.timeoutInterval = 60
            
            if isauthorizationToken {
                request.allHTTPHeaderFields = AuthorizationHeader()
                //let compression = WSCompression()
                self.socket =  WebSocket(request: request, useCustomEngine: true)
            }else{
                self.socket =  WebSocket(request: request)
            }
            return
        }
        
        guard !self.isConnected else {
            return
        }
        
        socket.connect()
    }
    func closeSocket(_ isforce:Bool=false) {
        guard let socket = self.socket else {
            return
        }
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
    
    // MARK: applicationDidEnterBackground
    @objc func applicationDidEnterBackground(_ notification: NSNotification?){
        Log("\(notification?.name.rawValue ?? "applicationDidEnterBackground")")
        self.webSocketQueue.isSuspended = true
        self.closeSocket()
    }
    
    @objc func applicationDidBecomeActiveNotification(_ notification: NSNotification?){
        Log("\(notification?.name.rawValue ?? "applicationDidBecomeActiveNotification")")
        self.webSocketQueue.isSuspended = false
        self.commitIntial()
    }
   
    @objc func willTerminateNotification(_ notification: NSNotification?){
        Log("\(notification?.name.rawValue ?? "willTerminateNotification")")
        self.webSocketQueue.isSuspended = false
        self.closeSocket(true)
        self.cancelAlloperation()
        NotificationCenter.default.removeObserver(self)
    }
}

extension WebSocketManager  :  WebSocketDelegate {
  
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            self.socket?.write(string: "[{\"ticket\":\"hey\"},{\"type\":\"ticker\",\"codes\":[\"KRW-BTC\"]}]", completion:nil)

        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            
        case .binary(let data):
            print("Received data: \(data.count)")
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
            isConnected = false
        case .error(let error):
            isConnected = false
            Log(String(describing: error))
            //handleError(error)
        case .peerClosed:
                   break
        }
    }
    
}


