//
//  UserDefault.swift
//  XCSClient
//
//  Created by Alex da Franca on 21.06.20.
//  Copyright © 2020 Farbflash. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(wrappedValue value: T, key: String) {
        self.key = key
        self.defaultValue = value
    }
    
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
