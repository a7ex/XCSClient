//
//  XcodeServer.swift
//  XCSClient
//
//  Created by Alex da Franca on 17.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

enum XcodeServer {
    case none, miniAgent01, miniAgent02, miniAgent03
    
    var ipAddress: String {
        switch self {
            case .miniAgent01:
                return "10.172.151.167"
            case .miniAgent02:
                return "10.172.151.191"
            case .miniAgent03:
                return "10.172.200.20"
            case .none:
                return ""
        }
    }
    
    var name: String {
        switch self {
            case .miniAgent01:
                return "Mac Mini 01"
            case .miniAgent02:
                return "Mac Mini 02"
            case .miniAgent03:
                return "Mac Mini 03"
            case .none:
                return "Select Xcode Server"
        }
    }
}
