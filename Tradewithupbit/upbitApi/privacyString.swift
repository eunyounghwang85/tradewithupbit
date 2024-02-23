//
//  privacyString.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation


struct credentialPreferences: Codable {
    let accesskey : String
    let secretkey : String
}

public var getAccesskey : String = {
    return getCredentialPlist("a") ?? ""
}()

public var getSecretkey : String = {
    return getCredentialPlist("s") ?? ""
}()


private var loadPreferences:credentialPreferences? = {
    
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

}()

private var getCredentialPlist:((String)->String?) = { key in
 
    guard let preferences = loadPreferences else {
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


