//
//  appString.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation


// MARK: MAINSIGN
public var MAINSIGN: String = Bundle.main.bundleIdentifier ?? "inavalidapp"

public var isauthorizationToken : Bool {
    return !getAccesskey.isEmpty  && !getSecretkey.isEmpty
}
public var AppUUID: String{
    get{
        guard let saveuuid = UserDefaults.standard.value(forKey: "AppUUID") as? String else {
            let fuuid = NSUUID.init().uuidString
            UserDefaults.standard.setValue(fuuid, forKey: "AppUUID")
            UserDefaults.standard.synchronize()
            return fuuid
        }
        return saveuuid
    }
}

