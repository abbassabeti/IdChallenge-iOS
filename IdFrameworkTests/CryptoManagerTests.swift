//
//  CryptoManagerTests.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import XCTest
@testable import IdFramework

final class CryptoManagerTests: XCTestCase {

    var cryptoManager: CryptoManager!
    var mockLegacyCrypto: MockLegacyCrypto!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Initialize the mock and the CryptoManager
        mockLegacyCrypto = MockLegacyCrypto()
        cryptoManager = CryptoManager(legacyCrypto: mockLegacyCrypto)
    }

    override func tearDownWithError() throws {
        cryptoManager = nil
        mockLegacyCrypto = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests for iOS 13+ (CryptoKit)

    @available(iOS 13.0, *)
    func testEncryptPhotoUsingCryptoKit_success() throws {
        // Given
        let testData = Data("test_photo".utf8)

        // When
        let encryptedData = try cryptoManager.encryptPhoto(testData)

        // Then
        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")
    }

    @available(iOS 13.0, *)
    func testDecryptPhotoUsingCryptoKit_success() throws {
        // Given
        let testData = Data("test_photo".utf8)
        let encryptedData = try cryptoManager.encryptPhoto(testData)

        // When
        let decryptedData = try cryptoManager.decryptPhoto(encryptedData)

        // Then
        XCTAssertEqual(decryptedData, testData, "Decrypted data should match the original data")
    }

    @available(iOS 13.0, *)
    func testDecryptPhotoUsingCryptoKit_failure() throws {
        // Given
        let badData = Data()

        // When & Then
        XCTAssertThrowsError(try cryptoManager.decryptPhoto(badData)) { error in
            XCTAssertEqual(error as? IDError, IDError.failedInDecryption, "Should throw failedInDecryption error")
        }
    }

    // MARK: - Tests for iOS 12 and earlier (LegacyCrypto)

    func testEncryptPhotoLegacy_success() throws {
        // Given
        let testData = Data("test_photo".utf8)

        // Simulate iOS 12 behavior (no CryptoKit)
        if #available(iOS 13.0, *) {
            throw XCTSkip("Skipping legacy test on iOS 13+")
        } else {
            let encryptedData = try cryptoManager.encryptPhoto(testData)
            XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")
            XCTAssertEqual(encryptedData, Data("mock_encrypted".utf8), "Encrypted data should match mock data")
        }
    }

    func testDecryptPhotoLegacy_success() throws {
        // Given
        let encryptedData = Data("mock_encrypted".utf8)

        // Simulate iOS 12 behavior (no CryptoKit)
        if #available(iOS 13.0, *) {
            throw XCTSkip("Skipping legacy test on iOS 13+")
        } else {
            let decryptedData = try cryptoManager.decryptPhoto(encryptedData)
            XCTAssertNotNil(decryptedData, "Decrypted data should not be nil")
            XCTAssertEqual(decryptedData, Data("mock_decrypted".utf8), "Decrypted data should match mock data")
        }
    }

    func testEncryptPhotoLegacy_failure() throws {
        // Given
        let testData = Data("test_photo".utf8)
        mockLegacyCrypto.shouldFailEncryption = true

        // Simulate iOS 12 behavior (no CryptoKit)
        if #available(iOS 13.0, *) {
            throw XCTSkip("Skipping legacy test on iOS 13+")
        } else {
            XCTAssertThrowsError(try cryptoManager.encryptPhoto(testData)) { error in
                XCTAssertEqual(error as? IDError, IDError.failedInEncryption, "Should throw failedInEncryption error")
            }
        }
    }

    func testDecryptPhotoLegacy_failure() throws {
        // Given
        let encryptedData = Data("mock_encrypted".utf8)
        mockLegacyCrypto.shouldFailDecryption = true

        // Simulate iOS 12 behavior (no CryptoKit)
        if #available(iOS 13.0, *) {
            throw XCTSkip("Skipping legacy test on iOS 13+")
        } else {
            XCTAssertThrowsError(try cryptoManager.decryptPhoto(encryptedData)) { error in
                XCTAssertEqual(error as? IDError, IDError.failedInDecryption, "Should throw failedInDecryption error")
            }
        }
    }
}
