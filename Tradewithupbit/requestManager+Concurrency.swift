//
//  requestManager+Concurrency.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
import Alamofire


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
    
    // MARK: alamofire Request
    func performArequest<T:Decodable>(_ request: URLRequestConvertible, _ result:T.Type) async throws -> T {
        
        
        let afresult =  await aF.request(request).validate().serializingDecodable(result).result
        switch afresult {
        case .success(let success):
            return success
        case .failure(let failure):
            throw RestError.withAlamo(failure)
        }
    }
        
}
