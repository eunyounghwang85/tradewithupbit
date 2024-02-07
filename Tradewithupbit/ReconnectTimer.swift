//
//  ReconnectTimer.swift
//  Tradewithupbit
//
//  Created by heyht on 1/30/24.
//

import Foundation
import UIKit

public let RECONNECT_TIMER:TimeInterval =  1.0
public let RECONNECT_TIMER_MAX_DEFAULT :TimeInterval = 64.0

class ReconnectTimer : NSObject {
    
    lazy var retryInterval:TimeInterval = .zero
    lazy var currentRetryInterval:TimeInterval = .zero
    lazy var maxRetryInterval : TimeInterval = .zero
    lazy var reconnetBlock:(()->Void) = {}
    lazy var timer:Timer? = nil {
        willSet{
            guard let timer = timer else {
                return
            }
            timer.invalidate()
        }
        didSet{
            guard let timer = timer else {
                return
            }
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
        self.stop()
    }
    
    @objc func resetRetryInterval(){
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
        self.reconnetBlock()
    }
}
