//
//  TestDevice.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 11.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct TestDevice: Codable {
    let ID: String? // "0f33329845994d52ec5013ca5c00f7ce",
    let activeProxiedDevice: ActiveProxiedDevice?
    let architecture: String? // "x86_64",
    let connected: Bool? // true,
    let deviceType: String? // "com.apple.iphone-simulator",
    let doc_type: String? // "device",
    let enabledForDevelopment: Bool? // true,
    let identifier: String? // "BE9A13D2-31B3-464A-A5F6-242BFE4604E3",
    let isServer: Bool? // false,
    let modelCode: String? // "iPhone11,2",
    let modelCodename: String? // "iPhone Xs",
    let modelName: String? // "iPhone Xs",
    let modelUTI: String? // "com.apple.iphone-xs-1",
    let name: String? // "iPhone Xs",
    let osVersion: String? // "12.2",
    let platformIdentifier: String? // "com.apple.platform.iphonesimulator",
    let retina: Bool? // false,
    let revision: String? // "724-9161aecc76fc6eada17a5fd6a0867f39",
    let simulator: Bool? // true,
    let supported: Bool? // true,
    let tinyID: String? // "951D6FF",
    let trusted: Bool? // true,
    let wireless: Bool? // false
}

struct ActiveProxiedDevice: Codable {
    let ID: String? // "0f33329845994d52ec5013ca5c00f7ce",
    let architecture: String? // "x86_64",
    let connected: Bool? // true,
    let deviceType: String? // "com.apple.iphone-simulator",
    let doc_type: String? // "device",
    let enabledForDevelopment: Bool? // true,
    let identifier: String? // "BE9A13D2-31B3-464A-A5F6-242BFE4604E3",
    let isServer: Bool? // false,
    let modelCode: String? // "iPhone11,2",
    let modelCodename: String? // "iPhone Xs",
    let modelName: String? // "iPhone Xs",
    let modelUTI: String? // "com.apple.iphone-xs-1",
    let name: String? // "iPhone Xs",
    let osVersion: String? // "12.2",
    let platformIdentifier: String? // "com.apple.platform.iphonesimulator",
    let retina: Bool? // false,
    let revision: String? // "724-9161aecc76fc6eada17a5fd6a0867f39",
    let simulator: Bool? // true,
    let supported: Bool? // true,
    let tinyID: String? // "951D6FF",
    let trusted: Bool? // true,
    let wireless: Bool? // false
}
