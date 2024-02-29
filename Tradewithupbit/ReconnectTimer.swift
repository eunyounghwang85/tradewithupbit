//
//  ReconnectTimer.swift
//  Tradewithupbit
//
//  Created by heyht on 1/30/24.
//

import Foundation
import UIKit

public let RECONNECT_TIMER:TimeInterval =  1.0
public let RECONNECT_TIMER_MAX_DEFAULT :TimeInterval = 60.0

class ReconnectTimer : NSObject {
    
    var retryInterval:TimeInterval!
    var currentRetryInterval:TimeInterval!
    var maxRetryInterval : TimeInterval!
    weak var timer:Timer? {
        willSet{
            guard let timer = timer, timer.isValid else {
                return
            }
        
            timer.invalidate()
        }
        didSet{
            guard let timer = timer else {
                return
            }
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    required init(_ retryInterval:TimeInterval, _ maxRetryInterval:TimeInterval) {
        super.init()
        self.retryInterval  = retryInterval
        self.currentRetryInterval = retryInterval
        self.maxRetryInterval = maxRetryInterval
        
    }
    
    deinit {
     
        self.timer = nil
    }
    
    @objc func resetRetryInterval(){
    
        self.currentRetryInterval = self.retryInterval
    }
    
    @objc func schedule(_ reconnetBlock:@escaping(()->Void)){
        /*
        if !Thread.isMainThread{
            DispatchQueue.main.async {
                self.schedule(reconnetBlock)
            }
        }*/
      
        Log("new Timer initail: \(String(describing: self.currentRetryInterval))")
        self.timer =  Timer.scheduledTimer(withTimeInterval: self.currentRetryInterval, repeats: false) {  [weak self] t in
            if t.isValid {
                t.invalidate()
            }
            guard let self = self else {return}
            Log("scheduled valid stop")
            if self.currentRetryInterval < self.maxRetryInterval {
                self.currentRetryInterval *= 2
            }
            
            reconnetBlock()
        }
     
    }
    
    @objc func stop(){
        Log("stop timer")
        self.timer = nil
    }
}
