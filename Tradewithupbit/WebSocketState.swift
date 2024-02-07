//
//  WebSocketState.swift
//  Tradewithupbit
//
//  Created by heyht on 1/30/24.
//

import Foundation

public enum WebSocketSessionState  {
    case starting
    case connecting
    case error(Error?)
    case connected
    case closing
    case closed
}

extension WebSocketSessionState : Equatable {
    public static func == (lhs: WebSocketSessionState, rhs: WebSocketSessionState) -> Bool {
        switch (lhs, rhs) {
        case (.starting, .starting),
            (.connecting, .connecting),
            (.connected, .connected),
            (.closing, .closing),
            (.closed, .closed),
            (.error(_), .error(_)):
                    return true
        default:
            return false
        }
    }
    
}
