//
//  GalleryInteractor.swift
//  IdChallenge
//
//  Created by Abbas Sabeti on 18.09.24.
//

import UIKit

protocol GalleryInteracting {
    func provideImages() -> [UIImage]
}

final class GalleryInteractor: GalleryInteracting {
    let images: [UIImage]
    
    init(images: [UIImage]) {
        self.images = images
    }
    
    func provideImages() -> [UIImage] {
        return images
    }
}
