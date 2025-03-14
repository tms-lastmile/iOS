//
//  KeyChainHelper.swift
//  TMSApp
//
//  Created by Abdillah Sulthan Naufal Panggabean on 13/03/25.
//

import Security
import Foundation

class KeychainHelper {
    static let shared = KeychainHelper()

    func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary

        SecItemDelete(query)
        SecItemAdd(query, nil)
    }

    func get(forKey key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        if SecItemCopyMatching(query, &result) == errSecSuccess {
            if let data = result as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }

    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary

        SecItemDelete(query)
    }
}
