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
    var buildNumber: String? // "17B102",
    var displayName: String? // "iOS",
    var identifier: String? // "com.apple.platform.iphoneos",
    var simulatorIdentifier: String? // "com.apple.platform.iphonesimulator",
    var version: String? // "13.2.2"
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case buildNumber, displayName, identifier, simulatorIdentifier, version
    }
}
