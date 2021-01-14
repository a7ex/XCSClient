//
//  Platform.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

/// The information required here can be found on the server machine with
/// ```
/// `sudo xcscontrol --list-platforms
/// ```
struct Platform: Codable {
    var id: String?
    var rev: String?
    var buildNumber: String?
    var displayName: String?
    var identifier: String?
    var simulatorIdentifier: String?
    var version: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case buildNumber, displayName, identifier, simulatorIdentifier, version
    }
    
    static var standard: Platform {
        return Platform(
            id: "FBB67329-5AD5-4B89-9CF3-FF99B4B10748",
            rev: "4-702448a6f15c1a9daeb380d2e7e8c863",
            buildNumber: "17B102",
            displayName: "iOS",
            identifier: "com.apple.platform.iphoneos",
            simulatorIdentifier: "com.apple.platform.iphonesimulator",
            version: "13.2.2"
        )
    }
}
