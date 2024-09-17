//
//  PrimaryInterface.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import UIKit

public final class IdVerification {
    let captureManager: PhotoCaptureManaging
    let storageService: PhotoAccessService
    let authService: AuthenticationService
    private var accessTimer: Timer?
    private var recentlyAuthorizedAccess: Bool = false
    
    init(
        captureManager: PhotoCaptureManaging,
        storageService: PhotoAccessService,
        authService: AuthenticationService
    ) {
        self.captureManager = captureManager
        self.storageService = storageService
        self.authService = authService
    }
    
    public init() {
        self.captureManager = PhotoCaptureManager()
        self.storageService = PhotoAccessManager(storageManager: .shared)
        self.authService = AuthenticationManager()
    }

    public func takePhoto(
        _ viewController: UIViewController,
        completion: @escaping (Result<Void,IDError>) -> Void
    ) {
        captureManager.capturePhoto(from: viewController) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let encryptedData):
                do {
                    try self.storageService.storeEncryptedData(encryptedData)
                    completion(.success(()))
                } catch let error {
                    if let _error = error as? IDError {
                        completion(.failure(_error))
                    } else {
                        completion(.failure(IDError.failedInStoringPhotos))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func authenticateUser(completion: @escaping (Result<Void,IDError>) -> Void) {
        authService.authenticateUser { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.recentlyAuthorizedAccess = true
                self.setTimer()
                completion(.success(()))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    public func accessPhotos(completion: @escaping (Result<[UIImage], IDError>) -> Void) {
        let loadPhotos = { [weak self] in
            guard let self else { return }
            do {
                try storageService.loadEncryptedData { images in
                    completion(.success(images))
                }
            } catch let error {
                if let _error = error as? IDError {
                    completion(.failure(_error))
                } else {
                    completion(.failure(IDError.failedInRetrievingPhotos))
                }
            }
        }
        if recentlyAuthorizedAccess {
            loadPhotos()
        } else {
            authenticateUser { result in
                switch result {
                case .success:
                    loadPhotos()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func setTimer() {
        self.accessTimer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(clearImageAccess),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc private func clearImageAccess() {
        self.recentlyAuthorizedAccess = false
    }
}
