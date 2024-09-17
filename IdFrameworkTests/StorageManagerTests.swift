//
//  StorageManagerTests.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 18.09.24.
//

import XCTest
@testable import IdFramework

class StorageManagerTests: XCTestCase {

    var storageManager: StorageManager!
    var temporaryDirectoryURL: URL!

    override func setUp() {
        super.setUp()
        
        let tempDirectory = NSTemporaryDirectory()
        let uniqueDirectory = UUID().uuidString
        temporaryDirectoryURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(uniqueDirectory)
        
        try! FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        
        storageManager = StorageManager(directoryURL: temporaryDirectoryURL)
    }

    override func tearDown() {
        super.tearDown()
        
        // Clean up the temporary directory after each test
        try? FileManager.default.removeItem(at: temporaryDirectoryURL)
        storageManager = nil
        temporaryDirectoryURL = nil
    }

    func testSaveEncryptedImage_Success() {
        let fileName = "testImage.dat"
        let data = "Test Data".data(using: .utf8)!
        
        do {
            try storageManager.saveEncryptedImage(data, fileName: fileName)
            
            // Verify the file exists
            let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        } catch {
            XCTFail("Saving encrypted image failed with error: \(error)")
        }
    }
    
    func testRetrieveAllEncryptedImages_Success() {
        let fileNames = ["image1.dat", "image2.dat", "image3.dat"]
        let dataList = ["Data1", "Data2", "Data3"].map { $0.data(using: .utf8)! }
        
        for (index, fileName) in fileNames.enumerated() {
            try! storageManager.saveEncryptedImage(dataList[index], fileName: fileName)
        }
        
        do {
            if let retrievedImages = try storageManager.retrieveAllEncryptedImages() {
                XCTAssertEqual(retrievedImages.count, fileNames.count, "Number of retrieved images does not match saved images")
                
                // Verify each retrieved image
                for retrievedImage in retrievedImages {
                    guard let index = fileNames.firstIndex(of: retrievedImage.fileName) else {
                        XCTFail("File Name does not exist")
                        continue
                    }
                    XCTAssertTrue(fileNames.contains(retrievedImage.fileName), "Retrieved file name is not expected")
                    XCTAssertEqual(retrievedImage.data, dataList[index], "Data for \(retrievedImage.fileName) does not match")
                }
            } else {
                XCTFail("Retrieved images array is nil")
            }
        } catch {
            XCTFail("Retrieving all encrypted images failed with error: \(error)")
        }
    }
    
    func testRetrieveAllEncryptedImages_NoImages() {
        do {
            let retrievedImages = try storageManager.retrieveAllEncryptedImages()
            XCTAssertEqual(retrievedImages?.count, 0, "Retrieved images should be empty when no images are saved")
        } catch {
            XCTFail("Retrieving all encrypted images failed with error: \(error)")
        }
    }
    
    func testSaveEncryptedImage_Failure() {
        let fileName = "/invalidPath/testImage.dat" // Invalid file name
        let data = "Test Data".data(using: .utf8)!
        
        XCTAssertThrowsError(try storageManager.saveEncryptedImage(data, fileName: fileName)) { error in
            XCTAssertEqual(error as? IDError, IDError.failedInStoringPhotos, "Expected failedInStoringPhotos error")
        }
    }
    
    func testRetrieveAllEncryptedImages_Failure() {
        // Delete the temporary directory to simulate a failure
        try! FileManager.default.removeItem(at: temporaryDirectoryURL)
        
        XCTAssertThrowsError(try storageManager.retrieveAllEncryptedImages()) { error in
            XCTAssertEqual(error as? IDError, IDError.failedInRetrievingPhotos, "Expected failedInRetrievingPhotos error")
        }
    }
}
