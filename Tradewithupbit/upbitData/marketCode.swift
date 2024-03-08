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


extension marketCode : Identifiable, Hashable {
    var id : String {
        return self.market
    }
    init(market:String = "", _ korean_name:String = "", _ english_name:String = "") {
        let data = try! JSONSerialization.data(withJSONObject: ["market":market,"korean_name":korean_name, "english_name":english_name])
        self = try! JSONDecoder().decode(Self.self, from: data)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id.hashValue)
      /*  hasher.combine(self.market.hashValue)
        hasher.combine(self.korean_name.hashValue)
        hasher.combine(self.english_name.hashValue)*/
      }
   /* static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }*/
}
 
