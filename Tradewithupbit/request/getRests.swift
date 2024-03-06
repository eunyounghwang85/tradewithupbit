//
//  getRests.swift
//  Tradewithupbit
//
//  Created by heyht on 3/6/24.
//

import Foundation

extension requestManager {
    static func getmarketAll() async throws -> [marketCode] {
        let request = try urlRequest(.marketAll)
        let manager = requestManager(request)
        return try await manager.performArequest(request, [marketCode].self)
        
    }
}
