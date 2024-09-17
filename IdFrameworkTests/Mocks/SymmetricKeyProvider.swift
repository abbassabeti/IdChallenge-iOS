//
//  SymmetricKeyProvider.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import Foundation
@testable import IdFramework

class MockSymmetricKeyProvider: SymmetricKeyProviding {
    var shouldFail: Bool

    init(shouldFail: Bool) {
        self.shouldFail = shouldFail
    }

    func retrieveSymmetricKeyData() throws -> Data {
        if shouldFail {
            throw IDError.failedInRetrievalOfKey
        } else {
            try generateKey()
        }
    }
    
    func generateSymmetricKey() throws -> Data {
        try generateKey()
    }
    
    private func generateKey() throws -> Data {
        if shouldFail {
            throw IDError.failedInRetrievalOfKey
        } else {
            return Data("MockKeyData".utf8)
        }
    }
}
