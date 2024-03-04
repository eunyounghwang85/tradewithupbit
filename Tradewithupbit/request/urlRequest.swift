//
//  urlRequest.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
import Alamofire

class urlRequest : URLRequestConvertible {

    let urlPath : String!
    required init(_ urlPath:String) throws {
      
        self.urlPath = urlPath
    }
    
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try urlPath.asURL()
        
        return try URLRequest(url: url,method: .get)
    }
}
