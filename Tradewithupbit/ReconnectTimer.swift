//
//  ReconnectTimer.swift
//  Tradewithupbit
//
//  Created by heyht on 1/30/24.
//

import Foundation
import UIKit

public let RECONNECT_TIMER:TimeInterval =  1.0
public let RECONNECT_TIMER_MAX_DEFAULT :TimeInterval = 5.0

class ReconnectTimer : NSObject {
    
    var retryInterval:TimeInterval!
    var currentRetryInterval:TimeInterval!
    var maxRetryInterval : TimeInterval!
    lazy var reconnetBlock:(()->Void) = {}
    lazy var timer:Timer? = nil {
        willSet{
            guard let timer = timer else {
                return
            }
            Log("timer invalidate")
            timer.invalidate()
        }
        didSet{
            guard let timer = timer else {
                return
            }
            Log("timer statrt \(timer.timeInterval)")
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    required init(_ retryInterval:TimeInterval, _ maxRetryInterval:TimeInterval, _ reconnetBlock:@escaping(()->Void)) {
        super.init()
        self.retryInterval  = retryInterval
        self.currentRetryInterval = retryInterval
        self.maxRetryInterval = maxRetryInterval
        self.reconnetBlock = reconnetBlock
        
    }
    
    deinit {
        self.reconnetBlock = {}
        self.stop()
    }
    
    @objc func resetRetryInterval(){
        
        Log("resetRetryInterval")
        self.currentRetryInterval = self.retryInterval
    }
    
    @objc func schedule(){
       
        self.timer = Timer.scheduledTimer(timeInterval:self.currentRetryInterval, target: self, selector:#selector(self.reconnect), userInfo: nil, repeats: false)
    }
    
    @objc func stop(){
        self.timer = nil
    }
    
    @objc func reconnect(){

        self.stop()
        
        if self.currentRetryInterval < self.maxRetryInterval {
            self.currentRetryInterval *= 2
        }
        
        Log("sreconnect: \(currentRetryInterval)")
        
        self.reconnetBlock()
    }
}
