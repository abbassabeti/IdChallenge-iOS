//
//  LegacyCryptoTests.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import XCTest
import CommonCrypto
@testable import IdFramework

final class LegacyCryptoTests: XCTestCase {

    var mockSymmetricKeyProvider: MockSymmetricKeyProvider!
    var realSymmetricKeyProvider: SymmetricKeyProvider!
    var legacyCryptoWithMockKey: LegacyCrypto!
    var legacyCryptoWithRealKey: LegacyCrypto!
    var testData: Data!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSymmetricKeyProvider = MockSymmetricKeyProvider(shouldFail: false)
        realSymmetricKeyProvider = SymmetricKeyProvider.shared
        legacyCryptoWithMockKey = LegacyCrypto(
            symmetricKeyProvider: mockSymmetricKeyProvider
        )
        legacyCryptoWithRealKey = LegacyCrypto(
            symmetricKeyProvider: realSymmetricKeyProvider
        )
        testData = Data("Test data for encryption".utf8)
    }

    override func tearDownWithError() throws {
        legacyCryptoWithMockKey = nil
        legacyCryptoWithRealKey = nil
        testData = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testEncryptPhotoLegacy_success() throws {
        // Given
        XCTAssertNotNil(testData)

        // When
        let encryptedData = try legacyCryptoWithRealKey.encryptPhotoLegacy(testData)

        // Then
        XCTAssertNotNil(
            encryptedData,
            "Encrypted data should not be nil"
        )
        XCTAssertNotEqual(
            encryptedData,
            testData,
            "Encrypted data should not be the same as the original data"
        )
    }

    func testDecryptPhotoLegacy_success() throws {
        // Given
        let encryptedData = try legacyCryptoWithRealKey.encryptPhotoLegacy(testData)
        XCTAssertNotNil(encryptedData)

        // When
        let decryptedData = try legacyCryptoWithRealKey.decryptPhotoLegacy(encryptedData)

        // Then
        XCTAssertNotNil(decryptedData, "Decrypted data should not be nil")
        XCTAssertEqual(
            decryptedData,
            testData,
            "Decrypted data should match the original data"
        )
    }

    func testEncryptPhotoLegacy_failureDueToKey() throws {
        // Given
        mockSymmetricKeyProvider.shouldFail = true

        // When & Then
        XCTAssertThrowsError(
            try legacyCryptoWithMockKey.encryptPhotoLegacy(testData)
        ) { error in
            XCTAssertEqual(
                error as? IDError,
                IDError.failedInRetrievalOfKey,
                "Expected failedInRetrievalOfKey error"
            )
        }
    }

    func testDecryptPhotoLegacy_failureDueToInvalidData() throws {
        // Given
        let invalidData = Data("Invalid data".utf8)

        // When & Then
        XCTAssertThrowsError(
            try legacyCryptoWithRealKey.decryptPhotoLegacy(invalidData)
        ) { error in
            XCTAssertEqual(
                error as? IDError,
                IDError.invalidData,
                "Expected invalidData error for incorrect input"
            )
        }
    }
}
