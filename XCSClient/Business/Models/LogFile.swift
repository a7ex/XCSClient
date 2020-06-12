//
//  LogFile.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 11.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct LogFile: Codable {
    let allowAnonymousAccess: Bool? // false,
    let fileName: String? // "xcodebuild_result.xcresult.zip",
    let isDirectory: Bool? // true,
    let relativePath: String? // "0f33329845994d52ec5013ca5c01292d-XCS LPS Dev Unit Tests/1/xcodebuild_result.xcresult.zip",
    let size: Int? // 14395490
}
