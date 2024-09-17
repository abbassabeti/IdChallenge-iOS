//
//  AuthenticationManagerTests.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import XCTest
import LocalAuthentication
@testable import IdFramework

final class AuthenticationManagerTests: XCTestCase {

    var authenticationManager: AuthenticationManager!
    var context: LAContext!
    override func setUpWithError() throws {
        try super.setUpWithError()
        authenticationManager = AuthenticationManager(contextProvider: { [weak self] in
            return self?.context ?? LAContext()
        })
    }

    override func tearDownWithError() throws {
        authenticationManager = nil
        try super.tearDownWithError()
    }
    
    func testAuthenticateUserSuccess() {
            // Given
            context = MockLAContext(shouldSucceed: true)
            let expectation = self.expectation(description: "Biometric authentication succeeds")

            // When
            authenticationManager.authenticateUser { result in
                // Then
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Authentication should succeed, but it failed.")
                }
            }

            waitForExpectations(timeout: 1.0, handler: nil)
        }

        func testAuthenticateUserFailureUnauthorizedFaceIDPermission() {
            // Given
            context = MockLAContext(
                shouldSucceed: false,
                errorCode: AuthenticationManager
                    .unauthorizedFaceIDPermissionErrorCode
            )
            let expectation = self.expectation(description: "Biometric authentication fails due to unauthorized FaceID")

            // When
            authenticationManager.authenticateUser { result in
                // Then
                switch result {
                case .success:
                    XCTFail("Authentication should fail, but it succeeded.")
                case .failure(let error):
                    XCTAssertEqual(error, IDError.biometryPermissionDenied)
                    expectation.fulfill()
                }
            }

            waitForExpectations(timeout: 1.0, handler: nil)
        }

        func testAuthenticateUserFailureNoIdentitiesEnrolled() {
            // Given
            context = MockLAContext(
                shouldSucceed: false,
                errorCode: AuthenticationManager.noIdentitiesAreEnrolledErrorCode
            )
            let expectation = self.expectation(description: "Biometric authentication fails due to no identities enrolled")

            // When
            authenticationManager.authenticateUser { result in
                // Then
                switch result {
                case .success:
                    XCTFail("Authentication should fail, but it succeeded.")
                case .failure(let error):
                    XCTAssertEqual(error, IDError.noIdentitiesEnrolled)
                    expectation.fulfill()
                }
            }

            waitForExpectations(timeout: 1.0, handler: nil)
        }

        func testAuthenticateUserFailureNotAuthorized() {
            // Given
            context = MockLAContext(
                shouldSucceed: false,
                errorCode: LAError.authenticationFailed.rawValue
            )

            let expectation = self.expectation(description: "Biometric authentication fails due to general not authorized error")

            // When
            authenticationManager.authenticateUser { result in
                // Then
                switch result {
                case .success:
                    XCTFail("Authentication should fail, but it succeeded.")
                case .failure(let error):
                    XCTAssertEqual(error, IDError.notAuthorized)
                    expectation.fulfill()
                }
            }

            waitForExpectations(timeout: 1.0, handler: nil)
        }
}
