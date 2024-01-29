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
    static func withQuery(_ query:[String:Any]? = nil) -> authParam {
        let requestString = {
            guard let query = query else {
                return ""
            }
            var components = URLComponents()
            components.queryItems = query.map { URLQueryItem(name: $0, value: "\($1)") }
            
            // SHA512 해줘야함
            return components.query!.digest(using: .sha512)
        }()
   
        return authParam(access_key: getAccesskey, nonce: AppUUID, query_hash:requestString, query_hash_alg:"SHA512")
    }
}


