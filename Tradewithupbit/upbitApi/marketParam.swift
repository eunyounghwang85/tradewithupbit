//
//  marketParam.swift
//  Tradewithupbit
//
//  Created by heyht on 1/29/24.
//

import Foundation

enum ticketType : String {
    case ticker // 현재가
    case trade // 체결
    case orderbook // 호가
}

enum formatType : String {
    case DEFAULT // 기본형
    case SIMPLE // 축약형
}


struct formatObj : Encodable {
    let format:String
   
    init(format: formatType) {
        
        self.format = format.rawValue
    }
}

struct ticketObj : Encodable {
    let ticket:String
}

struct marketParam : Encodable {
    
    let type:String
    var codes:[String]
    var isOnlySnapshot:Bool?  = nil
    var isOnlyRealtime:Bool?  = nil
    
    init(type: ticketType, codes: [String] =  [String](), isOnlySnapshot: Bool? = nil, isOnlyRealtime: Bool? = nil) {
        
        self.type = type.rawValue
        self.codes = codes
        self.isOnlySnapshot = isOnlySnapshot
        self.isOnlyRealtime = isOnlyRealtime
    }
}
