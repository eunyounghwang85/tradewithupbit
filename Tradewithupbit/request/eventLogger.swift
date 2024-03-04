//
//  eventLogger.swift
//  Tradewithupbit
//
//  Created by heyht on 3/4/24.
//

import Foundation
import Alamofire

struct eventLogger: EventMonitor {
    
    let queue = DispatchQueue(label: "requestManagerLogger")
    
    func requestDidFinish(_ request: Request) {
        Log("🛰 NETWORK Reqeust LOG")
        Log(request.description)

        Log(
        "URL: " + (request.request?.url?.absoluteString ?? "")  + "\n"
          + "Method: " + (request.request?.httpMethod ?? "") + "\n"
          + "Headers: " + "\(request.request?.allHTTPHeaderFields ?? [:])" + "\n"
      )
        Log("Authorization: " + (request.request?.headers["Authorization"] ?? ""))
        Log("Body: " + (request.request?.httpBody?.toPrettyPrintedString ?? ""))
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        Log("🛰 NETWORK Response LOG")
        Log(
          "URL: " + (request.request?.url?.absoluteString ?? "") + "\n"
            + "Result: " + "\(response.result)" + "\n"
            + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
            + "Data: \(response.data?.toPrettyPrintedString ?? "")"
        )
    }
}
