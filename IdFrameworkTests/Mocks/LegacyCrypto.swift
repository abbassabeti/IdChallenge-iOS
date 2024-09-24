//
//  LegacyCrypto.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import IdFramework
@testable import IdFramework

class MockLegacyCrypto: LegacyCryptoProtocol {
    var shouldFailEncryption = false
    var shouldFailDecryption = false

    func encryptPhotoLegacy(_ data: Data) throws -> Data {
        if shouldFailEncryption {
            throw IDError.failedInEncryption
        }
        return Data("mock_encrypted".utf8) // Simulated encrypted data
    }

    func decryptPhotoLegacy(_ encryptedData: Data) throws -> Data {
        if shouldFailDecryption {
            throw IDError.failedInDecryption
        }
        return Data("mock_decrypted".utf8) // Simulated decrypted data
    }
}
