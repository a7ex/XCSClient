//
//  Platform.swift
//  XCSClient
//
//  Created by Alex da Franca on 14.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct Platform: Codable {
    var id: String? // "cc9d81746914212693b3b4b3ba0043af",
    var rev: String? // "4-702448a6f15c1a9daeb380d2e7e8c863",
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
