//
//  PhotoAccessServiceImpl.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 18.09.24.
//


import UIKit
@testable import IdFramework

class MockPhotoAccessService: PhotoAccessService {
    var storeResult: Result<Void, Error> = .success(())
    var loadResult: Result<[UIImage], Error> = .success([])
    
    func storeEncryptedData(_ encryptedData: Data) throws {
        switch storeResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func loadEncryptedData(completion: @escaping ([UIImage]) -> Void) throws {
        switch loadResult {
        case .success(let images):
            completion(images)
        case .failure(let error):
            throw error
        }
    }
}
