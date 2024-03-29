//
//  ForegroundReconnection.swift
//  Tradewithupbit
//
//  Created by heyht on 1/30/24.
//

import Foundation
import  UIKit
import BackgroundTasks


enum AppState {
    case didFinishLaunchingWithOptions
    case applicationDidBecome
    case willResignActive
    case applicationDidEnterBackground
}
class ForegroundReconnection : NSObject {
    
    weak var sessionManager:WebSocketManager!
    lazy var backgroundTask : UIBackgroundTaskIdentifier? = nil {
        willSet{
            guard var task = backgroundTask else{
                return
            }
            UIApplication.shared.endBackgroundTask(task)
            task = .invalid
        }
    }
    lazy var appState:AppState = .didFinishLaunchingWithOptions
    
    init(sessionManager: WebSocketManager) {
        self.sessionManager = sessionManager
        super.init()
        
        // addobserver
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name:  UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecome(_:)), name:  UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(_:)), name:  UIApplication.willResignActiveNotification, object: nil)
        
    }
    deinit {
  
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: applicationDidEnterBackground
    @objc func applicationDidEnterBackground(_ notification: NSNotification?){
        Log("\(notification?.name.rawValue ?? "applicationDidEnterBackground")")
        appState = .applicationDidEnterBackground
        guard self.sessionManager.requiresTearDown else {
            return
        }
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            [weak self] in
            guard let self = self else {
                return
            }
            self.endBackgroundTask()
        })

    }

    @objc func applicationDidBecome(_ notification: NSNotification?){
        Log("\(notification?.name.rawValue ?? "applicationDidBecome")")
        appState = .applicationDidBecome
        endBackgroundTask()
        self.sessionManager.openSocket()
    }

    @objc func willResignActive(_ notification: NSNotification?){
        Log("\(notification?.name.rawValue ?? "willResignActive")")
        appState = .willResignActive
        self.sessionManager.closeSocket()
    }
    
    @objc func endBackgroundTask() {
        self.backgroundTask = nil
    }

   
}




