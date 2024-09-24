//
//  MockPhotoCaptureManager.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 18.09.24.
//

import UIKit
@testable import IdFramework

// Mock Photo Capture Manager
class MockPhotoCaptureManager: PhotoCaptureManaging {
    var captureResult: Result<Data, IDError> = .success(Data())
    
    func capturePhoto(from viewController: UIViewController, completion: @escaping (Result<Data, IDError>) -> Void) {
        completion(captureResult)
    }
}
