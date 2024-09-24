//
//  SymmetricKeyProvider.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 18.09.24.
//

import CryptoKit

final class SymmetricKeyProvider {
    
    static let shared = SymmetricKeyProvider()
    private let keyTag = "idVerify.symmetrickey"
    
    func generateSymmetricKey() throws -> Data {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        if result != errSecSuccess {
            throw IDError.failedInRetrievalOfKey
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keyTag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing key with the same tag
        SecItemDelete(query as CFDictionary)

        // Add the new key to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw IDError.failedInRetrievalOfKey
        }

        return keyData
    }

    // Retrieve the symmetric key from the Keychain
    func retrieveSymmetricKeyData() throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keyTag,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            if let keyData = result as? Data {
                return keyData
            } else {
                throw IDError.failedInRetrievalOfKey
            }
        } else if status == errSecItemNotFound {
            return try generateSymmetricKey()
        } else {
            throw IDError.failedInRetrievalOfKey
        }
    }
       
}
