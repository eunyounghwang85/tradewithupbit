//
//  requestManager+Combine.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
import Combine

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

}
