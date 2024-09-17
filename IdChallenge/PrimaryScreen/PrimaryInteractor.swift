//
//  PhotoInteractor.swift
//  IdChallenge
//
//  Created by Abbas Sabeti on 17.09.24.
//

import Foundation
import IdFramework
import UIKit

protocol PrimaryScreenInteracting {
    func takePhoto(from viewController: UIViewController)
    func authenticateUser()
    func loadPhotos()
}

final class PrimaryScreenInteractor: PrimaryScreenInteracting {
    
    let idVerifyManager: IdVerification
    let router: PrimaryScreenRouting
    
    init(
        idVerifyManager: IdVerification,
        router: PrimaryScreenRouting
    ) {
        self.idVerifyManager = idVerifyManager
        self.router = router
    }

    func takePhoto(from viewController: UIViewController) {
        idVerifyManager.takePhoto(viewController) { [weak self] result in
            guard let self else { return }
            guard case .failure(let error) = result else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.router.presentError(error)
            }
        }
    }
    
    func authenticateUser() {
        idVerifyManager.authenticateUser(completion: { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let failure):
                DispatchQueue.main.async { [weak self] in
                    self?.router.presentError(failure)
                }
            }
        })
    }
    
    func loadPhotos() {
        idVerifyManager.accessPhotos { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let images):
                    self.router.routeToGallery(images: images)
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        self?.router.presentError(error)
                    }
                }
            }
        }
    }
}
