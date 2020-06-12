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
}
