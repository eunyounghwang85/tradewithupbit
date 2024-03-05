//
//  urlRequest.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
import Alamofire

struct paramModel : Encodable {
    
    let key : String
    var value :  String? = nil
    
    init(key: String, value: Any? = nil) {
        self.key = key
        self.value = (value != nil) ? "\(value!)" : nil
    }
}
enum urlParameter {
    
    case query([paramModel])
    case queryblock([String]) // replacePath
    case body([String:Any])
    case bodyData(Data)
    case params([urlParameter])
    case none
    
}

extension urlParameter {
    
    var replacePaths :  [String]? {
        switch self {
        case .queryblock(let array):
            return array
        case .params(let array):
            let paths : [String] = array.compactMap({
                return $0.replacePaths
            }).flatMap({$0})
            return paths.isEmpty ?  nil :  paths
        default:
            return nil
        }
    }
    
    var queryItems : [URLQueryItem]? {
        switch self {
        case .query(let array):
            let querys:[URLQueryItem] = array.map({
                return URLQueryItem(name: $0.key, value: $0.value)
            })
            return querys
        case .params(let array):
            let querys : [URLQueryItem] = array.compactMap({
                return $0.queryItems
            }).flatMap({$0})
            return querys.isEmpty ?  nil :  querys
        default :
            return nil
        }
    }
    
    var httpBody : Data? {
        switch self {
        case .body(let dictionary):
            let bodys = dictionary.compactMapValues{$0 is NSNull ? nil : $0}
            guard let data = try? JSONSerialization.data(withJSONObject: bodys, options: [.prettyPrinted]) else {
                return nil
            }
            return data
        case .bodyData(let data):
            return data
        case .params(let array):
            let bodys : [Data] = array.compactMap({
                return $0.httpBody
            })
            return bodys.first
        default :
            return nil
        }
    }
}

struct urlRequest : URLRequestConvertible {

    let urlenum : upbitPath
    var method : HTTPMethod
    var param :  urlParameter
    init(_ urlenum:upbitPath, _ method:HTTPMethod = .get, _ param:urlParameter = .none) throws {
      
        self.urlenum = urlenum
        self.method = method
        self.param = param
    }
    
    
    func asURLRequest() throws -> URLRequest {
        
        var url = try urlenum.url()
        // path확인
        if var replacePaths = param.replacePaths {
            var newStringSeparator = url.absoluteString.components(separatedBy: "[[]]")
            var newpath = ""
            while !newStringSeparator.isEmpty {
                newpath += newStringSeparator.removeFirst()
                if !replacePaths.isEmpty {
                    newpath += replacePaths.removeFirst()
                }
                
                if newStringSeparator.isEmpty {
                    break
                }
            }
            url = try newpath.asURL()
        }
      
        if let queryItems = param.queryItems {
            var components =   URLComponents(string: url.absoluteString)!
            components.queryItems = queryItems
            url = components.url!
        }
        var request = try URLRequest(url: url,method: method)
        request.httpBody = param.httpBody
        
        
        return request
    }
}
