//
//  authParam.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation
import SwiftJWT



struct authParam : Claims {
    let access_key:String
    let nonce:String
    let query_hash:String
    let query_hash_alg:String
}

extension authParam {
    static func withQuery(_ query:String? = nil) -> authParam {
        let stringq = query ?? ""
        return authParam(access_key: getAccesskey, nonce: AppUUID, query_hash:stringq, query_hash_alg:"SHA512")
    }
}

internal func AuthorizationHeader(_ payload:authParam = authParam.withQuery()) -> [String:String] {
    var jwt = JWT(claims:payload)
    guard let signedJWT = try? jwt.sign(using: .hs256(key: getSecretkey.data(using: .utf8)!)) else {
        return [String:String]()
    }
    let authenticationToken = "Bearer " + signedJWT
    return ["Authorization": authenticationToken]
}
