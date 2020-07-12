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
    let relativePath: String?
    let size: Int?
}
