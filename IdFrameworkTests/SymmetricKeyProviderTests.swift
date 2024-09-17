//
//  SymmetricKeyProviderTests.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import XCTest
import Security
@testable import IdFramework

class SymmetricKeyProviderTests: XCTestCase {

    var symmetricKeyProvider: SymmetricKeyProvider!
    let keyTag = "idVerify.symmetrickey"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        symmetricKeyProvider = SymmetricKeyProvider.shared
        try deleteSymmetricKey()
    }

    override func tearDownWithError() throws {
        try deleteSymmetricKey()
        symmetricKeyProvider = nil
        try super.tearDownWithError()
    }
    
    private func deleteSymmetricKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keyTag
        ]
        SecItemDelete(query as CFDictionary)
    }

    func testGenerateSymmetricKey() throws {
        // Given
        let keyData = try symmetricKeyProvider.generateSymmetricKey()

        // Then
        XCTAssertNotNil(keyData)
        XCTAssertEqual(keyData.count, 32)

        // And When
        let retrievedKeyData = try symmetricKeyProvider.retrieveSymmetricKeyData()
        
        //Then
        XCTAssertEqual(retrievedKeyData, keyData)
    }

    func testRetrieveExistingSymmetricKey() throws {
        // Given
        let generatedKey = try symmetricKeyProvider.generateSymmetricKey()
        XCTAssertNotNil(generatedKey)

        // When
        let retrievedKey = try symmetricKeyProvider.retrieveSymmetricKeyData()

        // Then
        XCTAssertNotNil(retrievedKey)
        XCTAssertEqual(retrievedKey, generatedKey)
    }

    func testRetrieveSymmetricKeyWhenNotFound() throws {
        // Given
        try deleteSymmetricKey()

        // When
        let generatedKey = try symmetricKeyProvider.retrieveSymmetricKeyData()

        // Then
        XCTAssertNotNil(generatedKey)
        XCTAssertEqual(generatedKey.count, 32)
    }
}
