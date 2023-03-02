//
//  KeychainService.swift
//  Perfect Education with CYCU
//
//  Created by George on 2023/1/17.
//

import Foundation

class KeychainService {
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unhandledError(status: OSStatus)
    }
    
    // Query first stored login credential without passsword
    static func retrieveLoginInformation() throws -> MyselfDefinitions.LoginCredentials {
        let searchQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitAll,
                                    kSecReturnRef as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        // Get the first credential and return username wrapped inside LoginCredentials.
        guard let firstItem = (item as? [[String: Any]])?.first, let username = firstItem[kSecAttrAccount as String] as? String else {
            throw KeychainError.unexpectedPasswordData
        }
        return .init(username: username, password: nil)
    }
    
    // Query for specified login credential
    static func retrieveLoginCredentials(for credentials: MyselfDefinitions.LoginCredentials) throws -> MyselfDefinitions.LoginCredentials {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: credentials.username,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let passwordData = item as? Data, let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return .init(username: credentials.username, password: password)
    }
    
    // Creates new login credential
    static func registerLoginInformation(for credentials: MyselfDefinitions.LoginCredentials) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: credentials.username,
                                    kSecValueData as String: credentials.password?.data(using: .utf8) ?? Data()]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    // Updates credential information from keychain
    static func updateLoginInformation(for credentials: MyselfDefinitions.LoginCredentials) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: credentials.username,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        let attributes: [String: Any] = [kSecAttrAccount as String: credentials.username,
                                         kSecValueData as String: credentials.password ?? ""]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    // Removes specified credential from keychain
    static func removeLoginInformation(for credentials: MyselfDefinitions.LoginCredentials) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: credentials.username,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    // Removes all items inside keychain
    static func resetKeychain() throws {
        let searchQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitAll,
                                    kSecReturnRef as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        // Returned data type is based on the query
        if let existingItems = item as? [[String: Any]] {
            // Removes all items inside keychain
            try? existingItems.forEach { item in
                // Iterate through each existing keychain item's UUID
                if let uuidString = item["UUID"] {
                    // Important! Do not add this "kSecMatchLimit as String: kSecMatchLimitOne", this is not a property in SecItemDelete.
                    let deleteQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword, "UUID": uuidString]
                    let status = SecItemDelete(deleteQuery as CFDictionary)
                    guard status == errSecSuccess || status == errSecItemNotFound else {
                        throw KeychainError.unhandledError(status: status)
                    }
                }
            }
        }
    }
}
