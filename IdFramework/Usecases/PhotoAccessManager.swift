//
//  PhotoStorageManager.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import UIKit

protocol PhotoAccessService {
    func storeEncryptedData(_ encryptedData: Data) throws
    func loadEncryptedData(completion: @escaping ([UIImage]) -> Void) throws
}

final class PhotoAccessManager: PhotoAccessService {
    
    let storageManager: StorageManager

    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmssSSS"
        return formatter
    }()
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
    }
        
    func storeEncryptedData(_ data: Data) throws {
        do {
            let timestamp = dateFormatter.string(from: Date())
            let imageName = [timestamp,".jpg"].joined()
            let encryptedData = try CryptoManager.shared.encryptPhoto(data)
            try storageManager.saveEncryptedImage(encryptedData, fileName: imageName)
        } catch let error {
            if let _error = error as? IDError {
                throw _error
            } else {
                throw IDError.failedInStoringPhotos
            }
        }
    }

    func loadEncryptedData(completion: @escaping ([UIImage]) -> Void) throws {
        if let encryptedDataArray = try storageManager.retrieveAllEncryptedImages() {
            
            var decryptedImages = [UIImage]()
            
            let accessQueue = DispatchQueue(label: "idVerify.decryptedImagesAccessQueue")
            
            let imageCreationQueue = DispatchQueue(label: "idVerify.imageCreationQueue")
            
            let dispatchGroup = DispatchGroup()
            
            for (_, data) in encryptedDataArray {
                dispatchGroup.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    if let decryptedData = try? CryptoManager.shared.decryptPhoto(data) {
                        
                        imageCreationQueue.async {
                            autoreleasepool {
                                if let image = UIImage(data: decryptedData) {
                                    accessQueue.sync { [weak self] in
                                        guard let self else { return }
                                        if let preparedImage = self.prepareImage(image) {
                                            decryptedImages.append(preparedImage)
                                        }
                                    }
                                }
                                dispatchGroup.leave()
                            }
                        }
                    } else {
                        dispatchGroup.leave()
                    }

                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completion(decryptedImages)
            }
        } else {
            throw IDError.noStoredPhoto
        }
    }
    
    private func prepareImage(_ image: UIImage) -> UIImage? {
        if #available(iOS 15.0, *) {
            return image.preparingForDisplay()
        } else {
            return forceImageDecoding(image)
        }
    }

    private func forceImageDecoding(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: CGPoint.zero)
        let decodedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return decodedImage ?? image
    }
}
