//
//  ex+marketParam.swift
//  Tradewithupbit
//
//  Created by heyht on 1/30/24.
//

import Foundation
import SwiftJWT

// MARK: authParam
internal func AuthorizationHeader(_ payload:authParam = authParam.withQuery()) -> [String:String] {
    var jwt = JWT(claims:payload)
    
    guard let signedJWT = try? jwt.sign(using: .hs256(key: getSecretkey.data(using: .utf8)!)) else {
        return [String:String]()
    }
    
    let authenticationToken = "Bearer " + signedJWT
    return ["Authorization": authenticationToken]
    
}

// MARK: marketParam
internal func sendFormesseage(market:[marketParam], _ form:formatObj? = nil) ->  String {
    var dicArr:[Encodable] = market
    dicArr.insert(ticketObj(ticket: "!!hey!!"), at: 0)
    if let form = form {
        dicArr.append(form)
    }
    return dicArr.toString()
}
extension marketParam {
    internal func SendForm(_ form:formatObj? = nil) ->  String {
        var dicArr:[Encodable] = [ticketObj(ticket: "hey"), self]
        if let form = form {
            dicArr.append(form)
        }
        return dicArr.toString()
    }

}

