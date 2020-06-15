//
//  NSError+ConvenienceInit.swift
//  xcodeserverclient
//
//  Created by Alex da Franca on 08.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(message: String, status: Int = 1) {
        let domain = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "com.farbflash"
        self.init(domain: "\(domain).error", code: status, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    convenience init(jumpHostError: Data, status: Int) {
        let domain = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "com.farbflash"
        let message: String
        let msg = String(data: jumpHostError, encoding: .utf8) ?? "Unknown"
        if msg.contains("* USAGE WARNING *") {
            let lines = msg.components(separatedBy: "\n")
            message = lines.dropFirst(12).joined(separator: "\n")
        } else {
            message = msg
        }
        self.init(domain: "\(domain).error", code: status, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
