//
//  Util.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation

// MARK: DispatchQueue
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

