//
//  CDLogFile+Codable.swift
//  XCSClient
//
//  Created by Alex da Franca on 27.12.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation
import CoreData

extension CDLogFile {
    func update(with logFile: LogFile) {
        allowAnonymousAccess = logFile.allowAnonymousAccess ?? false
        fileName = logFile.fileName
        isDirectory = logFile.isDirectory ?? false
        relativePath = logFile.relativePath
        size = Int64(logFile.size ?? 0)
    }
}

extension CDLogFile {
    var asCodableObject: LogFile {
        return LogFile(
            allowAnonymousAccess: allowAnonymousAccess,
            fileName: fileName,
            isDirectory: isDirectory,
            relativePath: relativePath,
            size: Int(size)
        )
    }
}
