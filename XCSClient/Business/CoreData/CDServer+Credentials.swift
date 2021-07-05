//
//  CDServer+Credentials.swift
//  XCSClient
//
//  Created by Alex da Franca on 04.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

private let kcId = "com.farbflash.XCSClient.secureCreds"

extension CDServer {
    var secureCredentials: SecureCredentials? {
        get {
            guard let id = id else {
                return nil
            }
            return SecureCredentials(service: kcId, account: id)
        }
    }
    var secret: String? {
        get {
            guard let credentials = secureCredentials else {
                return nil
            }
            guard let secret = try? credentials.readSecret(),
                  !secret.isEmpty else {
                return nil
            }
            return secret
        }
        set {
            guard let credentials = secureCredentials else {
                return
            }
            if let secret = newValue {
                try? credentials.saveSecret(secret)
            } else {
                try? credentials.deleteItem()
            }
        }
    }
}
