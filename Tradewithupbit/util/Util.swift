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

// MARK: Array where Element == Encodable
extension Array where Element == Encodable {
    func toString() -> String {
        
        var result = ""
        var values = self
        while !values.isEmpty {
            let e = values.removeFirst()
            result += result.isEmpty ? "[\(e.toString())" : ",\(e.toString())"
            if values.isEmpty {
                result += "]"
                break
            }
        }
        
        return result
    }
}

// MARK: Encodable
extension Encodable {
    func toString() -> String {
        guard let data = try? JSONEncoder().encode(self) else {
            return ""
        }
        
        let result = String(decoding: data, as: UTF8.self)
        return result
    }
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any] else { return [:] }
        return dictionaryData
    }
    
    func toarray() -> [[Any]] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [[Any]] else { return [[]] }
        return dictionaryData
    }

}

// MARK: Data
extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
