//
//  PrimaryScreenRouting.swift
//  IdChallenge
//
//  Created by Abbas Sabeti on 18.09.24.
//

import UIKit
import IdFramework

protocol PrimaryScreenRouting {
    func routeToGallery(images: [UIImage])
    func presentError(_ error: IDError)
}

final class PrimaryScreenRouter: PrimaryScreenRouting {
    
    weak var primaryVC: UIViewController?
    
    func routeToGallery(images: [UIImage]) {
        guard let primaryVC else { return }
        let interactor = GalleryInteractor(images: images)
        let galleryVC = GalleryViewController(interactor: interactor)
        primaryVC.present(galleryVC, animated: true)
    }
    
    func loadPrimaryScreen() -> UIViewController {
        let interactor = PrimaryScreenInteractor(
            idVerifyManager: IdVerification(),
            router: self
        )
        let controller = PrimaryViewController(interactor: interactor)
        self.primaryVC = controller
        return controller
    }
    
    func presentError(_ error: IDError) {
        guard let primaryVC else { return }
        let alertController = UIAlertController(
            title: "Error",
            message: error.description,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
        alertController.addAction(okAction)

        primaryVC.present(alertController, animated: true, completion: nil)
    }
}
