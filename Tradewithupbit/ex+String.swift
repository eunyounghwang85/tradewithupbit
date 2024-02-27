//
//  ex+String.swift
//  Tradewithupbit
//
//  Created by heyht on 2/27/24.
//

import Foundation
import SwiftUI


@available(macOS 10.15, *)
@available(iOS 15, *)
public extension LocalizedStringKey {
    func localizedStr(_ args: [CVarArg]? = nil ) -> String {
        //use reflection
        let mirror = Mirror(reflecting: self)
        
        //try to find 'key' attribute value
        let attributeLabelAndValue = mirror.children.first { (arg0) -> Bool in
            let (label, _) = arg0
            
            return label == "key"
        }
        if #available(iOS 16, *) {
             
            return  String(localized: LocalizedStringResource(stringLiteral: attributeLabelAndValue!.value as! String))
            //LocalizedStringResource.localizedStr(attributeLabelAndValue!.value as! StringLiteralType)
        }else{
         
            if attributeLabelAndValue != nil {
                if let args = args {
                    return String.localizedStringWithFormat(NSLocalizedString(attributeLabelAndValue!.value as! String, comment: ""), args )
                }
                
                //ask for localization of found key via NSLocalizedString
                return String.localizedStringWithFormat(NSLocalizedString(attributeLabelAndValue!.value as! String, comment: ""))
            } else {
                return "Swift LocalizedStringKey signature must have changed. @see Apple documentation."
            }
            
        }
    }
}


@available(macOS 13, *)
@available(iOS 16, *)
@available(watchOS 9, *)
public extension LocalizedStringResource {
    
    static func localizedStr(_ key:String) -> String {
        let localr = LocalizedStringResource(stringLiteral: key)
        let localsString = String(localized: localr)
        Log(localsString)
       // Log(">> >>: \(key) - \( localr ) ")
        return localsString
    }
}

@available(macOS 10.15, *)
@available(iOS 15, *)
public extension String {
    var localized: String {
        return LocalizedStringKey(self).localizedStr()
    }
    
    func localized(params: [String]) -> String {
        return LocalizedStringKey(self).localizedStr(params)
    }
}

