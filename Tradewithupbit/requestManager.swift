//
//  requestManager.swift
//  Tradewithupbit
//
//  Created by heyht on 2/29/24.
//

import Foundation


enum RestError: Error {
    case invalid(Int)
    case unknown(Error)
    case failedresponse
}



struct requestManager  {
    
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
      self.session = session
    }

}
