//
//  requestManager+Combine.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
import Combine
import Alamofire


extension requestManager {
    
    func performRequest(_ request: URLRequest) -> AnyPublisher<Data, RestError> {
        
     
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw RestError.failedresponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw RestError.invalid(httpResponse.statusCode)
                }
                
                return data
            }
            .mapError { error in
                if let networkingError = error as? RestError {
                    return networkingError
                } else {
                    return .unknown(error)
                }
            } // Returns: An ``AnyPublisher`` wrapping this publisher.
            .eraseToAnyPublisher()
    }
    
    // MARK: alamofire Request
    func performArequest<T:Decodable>(_ request: URLRequestConvertible, _ result:T.Type) -> AnyPublisher<T, RestError> {
        
        return aF.request(request)
            .validate()
            .publishDecodable(type:result)
            .result()
            .tryMap { r in
                switch r {
                case .success(let success):
                    return success
                case .failure(let failure):
                    throw RestError.withAlamo(failure)
                }
            }.mapError { error in
                if let networkingError = error as? RestError {
                    return networkingError
                } else {
                    return .unknown(error)
                }
            }.eraseToAnyPublisher()
        
    }
    

}
