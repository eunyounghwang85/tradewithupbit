//
//  WebSocketManager.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation
import UIKit
import Starscream


extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(token: String, block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    func async(block: @escaping ()->()) {
        self.async(execute: block)
    }
    
    func after(time: DispatchTime, block: @escaping ()->()) {
        self.asyncAfter(deadline: time, execute: block)
    }
}

// MARK: Log
public func Log(_ nslog: String, _ fnc:String = #function, _ line:Int = #line)->(){
    
    #if DEBUG
    print("[swiftIN]  \(nslog)",fnc,line)
    #endif
    
}

// MARK: synchronized(self)
@discardableResult
public func synchronized<T>(_ lock: AnyObject, closure:() -> T) -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }

    return closure()
}



// MARK: MAINSIGN
public var MAINSIGN: String = Bundle.main.bundleIdentifier ?? "inavalidapp"

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
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name:  UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification(_:)), name:  UIApplication.didBecomeActiveNotification, object: nil)
        
        var request = URLRequest(url: URL(string: "wss://api.upbit.com/websocket/v1")!)
        request.timeoutInterval = 5
        self.socket =  WebSocket(request: request)
        
    }
    
    deinit {
        self.cancelAlloperation()
        NotificationCenter.default.removeObserver(self)
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
        Log("mqttManager <<applicationDidEnterBackground>>")
        self.webSocketQueue.isSuspended = true
        
    }
    
    @objc func applicationDidBecomeActiveNotification(_ notification: NSNotification?){
        Log("mqttManager <<applicationDidBecomeActiveNotification>>")
        self.webSocketQueue.isSuspended = false
    }
   
    
}

extension WebSocketManager  :  WebSocketDelegate {
  
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            self.socket?.write(string: "[\n" +
                               "  {\n" +
                               "    \"ticket\": \"test example\"\n" +
                               "  },\n" +
                               "  {\n" +
                               "    \"type\": \"ticker\",\n" +
                               "    \"codes\": [\n" +
                               "      \"KRW-BTC\",\n" +
                               "      \"KRW-ETH\"\n" +
                               "    ]\n" +
                               "  },\n" +
                               "  {\n" +
                               "    \"format\": \"DEFAULT\"\n" +
                               "  }\n" +
                               "]", completion:nil)

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


