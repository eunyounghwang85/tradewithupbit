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
 
    var tryClose : Bool {
        guard self.requiresTearDown else {
            return true
        }
        return self == .closing
    }
    var tryConnected : Bool {
        return self == .connected || self == .connecting
    }
    var requiresTearDown : Bool {
        return self != .closed && self != .starting
    }

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
