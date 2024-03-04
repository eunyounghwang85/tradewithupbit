//
//  upbitPath.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
enum upbitPath : String {
    case socketV1 = "api.upbit.com/websocket/v1"
    case marketAll = "market/all"
}

extension upbitPath {
    static let defaultPrefix = "https://api.upbit.com/v1/"
    
    private var path: String {
        return self.rawValue
    }
    
    func withHttps () throws -> String {
        guard self != .socketV1 else {
            throw RestError.urlpathWrong
        }
        
        return upbitPath.defaultPrefix + self.path
     
    }
    
    func withWss() throws -> String {
        guard self == .socketV1 else {
            throw RestError.urlpathWrong
        }
        return "wss://" + self.path
    }
    
    func url() throws -> URL {
        
        do {
            let path : String
            switch self {
            case .socketV1:
                path = try withWss()
            default:
                path = try withHttps()
            }
            guard let url = URL(string: path) else { 
                throw RestError.urlpathWrong
            }
            return url
        }catch {
            throw error
        }
    }
}
