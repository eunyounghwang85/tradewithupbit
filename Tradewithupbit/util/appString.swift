//
//  appString.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation


// MARK: MAINSIGN
public var MAINSIGN: String = Bundle.main.bundleIdentifier ?? "inavalidapp"

struct credentialPreferences: Codable {
    let accesskey : String
    let secretkey : String
}

public var getAccesskey : String = {
    return getSettingPlist("a") ?? ""
}()

public var getSecretkey : String = {
    return getSettingPlist("s") ?? ""
}()

public var isauthorizationToken : Bool {
    return !getAccesskey.isEmpty  && !getSecretkey.isEmpty
}
private var getPreferences:credentialPreferences? = {
    
    guard let path = Bundle.main.path(forResource: "privacyToken", ofType: "plist"),
          let xml  = FileManager.default.contents(atPath: path) else {
        return nil
    }
    
    do {
        let preferences = try PropertyListDecoder().decode(credentialPreferences.self, from: xml)
        return preferences
    }catch {
        Log("\(error)")
        return nil
    }
    
    
   /* guard let path = Bundle.main.path(forResource: "privacyToken", ofType: "plist"),
          let xml  = FileManager.default.contents(atPath: path),
          let preferences = try? PropertyListDecoder().decode(credentialPreferences.self, from: xml) else {
        return nil
    }

    return preferences*/
}()
private var getSettingPlist:((String)->String?) = { key in
 
    guard let preferences = getPreferences else {
        return nil
    }
   
    switch key {
    case "a":
        return preferences.accesskey
    case "s":
        return preferences.secretkey
    default:
        return ""
    }

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

