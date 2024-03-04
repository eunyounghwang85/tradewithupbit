//
//  requestManager.swift
//  Tradewithupbit
//
//  Created by heyht on 2/29/24.
//

import Foundation
import Alamofire

enum RestError: Error {
    case invalid(Int)
    case unknown(Error)
    case withAlamo(AFError)
    case failedresponse
    case urlpathWrong
}

let aF :  Session =  {
    
    let configuration = URLSessionConfiguration.af.default
    let apiLogger = eventLogger()
    return Session(configuration: configuration, eventMonitors: [apiLogger])
    
}()

struct requestManager  {
    
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
      self.session = session
    }
    
    init (){
        
        // alamofire rest와 비교하기 위함 으로 일단 유지
        self.session = aF.session
    }

}
