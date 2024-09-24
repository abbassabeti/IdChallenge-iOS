//
//  IdVerificationTests.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 18.09.24.
//

import XCTest
import UIKit
@testable import IdFramework

class IdVerificationTests: XCTestCase {
    
    var idVerification: IdVerification!
    var mockCaptureManager: MockPhotoCaptureManager!
    var mockStorageService: MockPhotoAccessService!
    var mockAuthService: MockAuthenticationService!
    
    override func setUp() {
        super.setUp()
        mockCaptureManager = MockPhotoCaptureManager()
        mockStorageService = MockPhotoAccessService()
        mockAuthService = MockAuthenticationService()
        idVerification = IdVerification(
            captureManager: mockCaptureManager,
            storageService: mockStorageService,
            authService: mockAuthService
        )
    }
    
    override func tearDown() {
        idVerification = nil
        mockCaptureManager = nil
        mockStorageService = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    // MARK: - Tests for takePhoto
    
    func testTakePhoto_Success() {
        // Given
        let expectedData = "TestData".data(using: .utf8)!
        mockCaptureManager.captureResult = .success(expectedData)
        mockStorageService.storeResult = .success(())
        
        let expectation = self.expectation(description: "takePhotoSuccess")
        
        // Then
        idVerification.takePhoto(UIViewController()) { result in
            
            switch result {
            case .success():
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testTakePhoto_CaptureFailure() {
        // Given
        mockCaptureManager.captureResult = .failure(IDError.failedInCapture)
        
        let expectation = self.expectation(description: "takePhotoCaptureFailure")
        
        // Then
        idVerification.takePhoto(UIViewController()) { result in
            
            switch result {
            case .success():
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, IDError.failedInCapture, "Expected failedInCapture error")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testTakePhoto_StorageFailure() {
        // Given
        let expectedData = "TestData".data(using: .utf8)!
        mockCaptureManager.captureResult = .success(expectedData)
        mockStorageService.storeResult = .failure(IDError.failedInStoringPhotos)
        
        let expectation = self.expectation(description: "takePhotoStorageFailure")
        
        // Then
        idVerification.takePhoto(UIViewController()) { result in
            
            switch result {
            case .success():
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, IDError.failedInStoringPhotos, "Expected failedInStoringPhotos error")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - Tests for authenticateUser
    
    func testAuthenticateUser_Success() {
        // Given
        mockAuthService.resultToReturn = .success(())
        let expectation = self.expectation(description: "authenticateUserSuccess")
        
        // Then
        idVerification.authenticateUser { result in
            
            switch result {
            case .success():
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAuthenticateUser_Failure() {
        // Given
        mockAuthService.resultToReturn = .failure(IDError.notAuthorized)
        let expectation = self.expectation(description: "authenticateUserFailure")
        // Then
        idVerification.authenticateUser { result in
            switch result {
            case .success():
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, IDError.notAuthorized, "Expected notAuthorized error")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // MARK: - Tests for accessPhotos
    
    func testAccessPhotos_Authorized_Success() {
        // Given
        mockAuthService.resultToReturn = .success(())
        mockStorageService.loadResult = .success([UIImage()])
        let expectation = self.expectation(description: "accessPhotosAuthorizedSuccess")
        
        // When
        idVerification.authenticateUser(completion: { _ in })
        
        // Then
        idVerification.accessPhotos { result in
            
            switch result {
            case .success(let images):
                XCTAssertEqual(images.count, 1, "Expected one image")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAccessPhotos_NotAuthorized_AuthenticateSuccess_LoadSuccess() {
        // Given
        mockAuthService.resultToReturn = .failure(IDError.notAuthorized)
        mockStorageService.loadResult = .success([UIImage()])
        let expectation = self.expectation(description: "accessPhotosAuthenticateSuccess")
        
        // When
        idVerification.authenticateUser(completion: { _ in })
        
        mockAuthService.resultToReturn = .success(())
        
        // Then
        idVerification.accessPhotos { result in
            switch result {
            case .success(let images):
                XCTAssertEqual(images.count, 1, "Expected one image")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAccessPhotos_NotAuthorized_AuthenticateFailure() {
        mockAuthService.resultToReturn = .failure(IDError.notAuthorized)
        let expectation = self.expectation(description: "accessPhotosAuthenticateFailure")
        
        idVerification.authenticateUser(completion: { _ in })
        
        idVerification.accessPhotos { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, IDError.notAuthorized, "Expected notAuthorized error")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAccessPhotos_Authorized_LoadFailure() {
        mockAuthService.resultToReturn = .success(())
        mockStorageService.loadResult = .failure(IDError.noStoredPhoto)
        let expectation = self.expectation(description: "accessPhotosLoadFailure")
        
        idVerification.authenticateUser(completion: { _ in })
        mockAuthService.resultToReturn = .failure(IDError.notAuthorized)
        idVerification.accessPhotos { result in
            
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, IDError.noStoredPhoto, "Expected noStoredPhoto error")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
