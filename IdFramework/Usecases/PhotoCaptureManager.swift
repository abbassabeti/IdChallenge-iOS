//
//  PhotoCaptureManager.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import CommonCrypto
import CryptoKit
import UIKit

protocol PhotoCaptureManaging {
    func capturePhoto(from viewController: UIViewController, completion: @escaping (Result<Data, IDError>) -> Void)
}

final class PhotoCaptureManager:
    NSObject,
    PhotoCaptureManaging,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    
    private var completion: ((Result<Data, IDError>) -> Void)?
    
    func capturePhoto(from viewController: UIViewController, completion: @escaping (Result<Data, IDError>) -> Void) {
        self.completion = completion
        
        let imagePicker = IDImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.delegate = self
        viewController.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[.originalImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion?(.failure(IDError.failedInCapture))
            return
        }

        completion?(.success(imageData))
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        completion?(.failure(IDError.captureCancelledByUser))
    }
}

