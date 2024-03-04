//
//  requestManager+Concurrency.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation



extension requestManager {
    
    func performRequest(_ request: URLRequest) async throws -> Data {
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RestError.failedresponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw RestError.invalid(httpResponse.statusCode)
        }
        
        return data
    }
    
}
