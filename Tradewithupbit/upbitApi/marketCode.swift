//
//  marketCode.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation

struct marketCode : Codable
{
   
    let market:String
    let korean_name:String
    let english_name:String

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        market = (try? values.decode(String.self, forKey: .market)) ?? ""
        korean_name = (try? values.decode(String.self, forKey: .korean_name)) ?? ""
        english_name = (try? values.decode(String.self, forKey: .english_name)) ?? ""
    }
}


extension marketCode : Identifiable {
    var id : String {
        return self.market
    }
}
 
