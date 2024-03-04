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
        self.session = aF.session
    }

}
