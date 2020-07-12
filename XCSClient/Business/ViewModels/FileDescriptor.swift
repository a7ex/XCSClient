//
//  FileDescriptor.swift
//  XCSClient
//
//  Created by Alex da Franca on 12.07.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

struct FileDescriptor {
    static let byteFormatter = ByteCountFormatter()
    let name: String
    let path: String
    let size: Int
    
    var title: String {
        return "\(name) (\(Self.byteFormatter.string(fromByteCount: Int64(size))))"
    }
    
    init(logFile: LogFile?) {
        if let logFile = logFile,
            let path = logFile.relativePath, !path.isEmpty,
            let size = logFile.size, size > 0 {
            
            name = logFile.fileName ?? String(path.split(separator: "/").last ?? "")
            self.path = path
            self.size = size
        } else {
            name = ""
            path = ""
            size = 0
        }
    }
}
