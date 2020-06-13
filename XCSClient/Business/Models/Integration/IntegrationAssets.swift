//
//  IntegrationAssets.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 11.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct IntegrationAssets: Codable {
    let archive: LogFile?
    let buildServiceLog: LogFile?
    let sourceControlLog: LogFile?
    let xcodebuildLog: LogFile?
    let xcodebuildOutput: LogFile?
    let triggerAssets: [LogFile]?
}
