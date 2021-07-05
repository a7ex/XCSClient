//
//  SecureCredentials.swift
//  XCSClient
//
//  Created by Alex da Franca on 04.07.21.
//  Copyright © 2021 Farbflash. All rights reserved.
//

import Foundation

struct SecureCredentials {
    
    // MARK: Types
    
    enum SecureCredentialsError: Error {
        case noSecret
        case unexpectedSecretData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Properties
    
    let service: String
    
    private(set) var account: String
    
    let accessGroup: String?
    
    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    func readSecret() throws -> String {
        var query = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard status != errSecItemNotFound else {
            throw SecureCredentialsError.noSecret
        }
        guard status == noErr else {
            throw SecureCredentialsError.unhandledError(status: status)
        }
        guard let existingItem = queryResult as? [String : AnyObject],
              let secretData = existingItem[kSecValueData as String] as? Data,
              let secret = String(data: secretData, encoding: String.Encoding.utf8) else {
            throw SecureCredentialsError.unexpectedSecretData
        }
        return secret
    }
    
    func saveSecret(_ secret: String) throws {
        let secretData = Data(secret.utf8)
        do {
            try _ = readSecret()
            
            // Update the existing item with the new secret.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = secretData as AnyObject?
            
            let query = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else {
                throw SecureCredentialsError.unhandledError(status: status)
            }
        } catch SecureCredentialsError.noSecret {
            var newItem = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = secretData as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else {
                throw SecureCredentialsError.unhandledError(status: status)
            }
        }
    }
    
    func deleteItem() throws {
        let query = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else {
            throw SecureCredentialsError.unhandledError(status: status)
        }
    }
    
//    /// Fetch all items that match the service and access group.
//    static func passwordItems(forService service: String, accessGroup: String? = nil) throws -> [SecureCredentials] {
//        var query = Self.keychainQuery(withService: service, accessGroup: accessGroup)
//        query[kSecMatchLimit as String] = kSecMatchLimitAll
//        query[kSecReturnAttributes as String] = kCFBooleanTrue
//        query[kSecReturnData as String] = kCFBooleanFalse
//
//        var queryResult: AnyObject?
//        let status = withUnsafeMutablePointer(to: &queryResult) {
//            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
//        }
//        guard status != errSecItemNotFound else {
//            return []
//        }
//        guard status == noErr else {
//            throw SecureCredentialsError.unhandledError(status: status)
//        }
//        guard let resultData = queryResult as? [[String : AnyObject]] else {
//            throw SecureCredentialsError.unexpectedItemData
//        }
//        var allCredentials = [SecureCredentials]()
//        for result in resultData {
//            guard let account = result[kSecAttrAccount as String] as? String else {
//                throw SecureCredentialsError.unexpectedItemData
//            }
//            let credential = SecureCredentials(service: service, account: account, accessGroup: accessGroup)
//            allCredentials.append(credential)
//        }
//        return allCredentials
//    }
    
    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        return query
    }
}

extension SecureCredentials {
    var loginData: (username: String, password: String)? {
        guard let secret = try? readSecret() else {
            return nil
        }
        let parts = secret.components(separatedBy: ":")
        guard parts.count > 1,
              let uname = parts.first else {
            return nil
        }
        let password = parts.dropFirst().joined(separator: ":")
        return (username: uname, password: password)
    }
}
