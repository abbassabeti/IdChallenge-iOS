//
//  ErrorHandling.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import Foundation

public enum IDError: Error {
    case failedInCapture
    case captureCancelledByUser
    case failedInEncryption
    case failedInDecryption
    case failedInStoringPhotos
    case failedInRetrievingPhotos
    case invalidData
    case notAuthorized
    case biometryPermissionDenied
    case noIdentitiesEnrolled
    case failedInRetrievalOfKey
    case noStoredPhoto
    
    public var description: String {
        switch self {
        case .failedInCapture:
            return "Failed In Capturing Image"
        case .captureCancelledByUser:
            return "Capture cancelled by user"
        case .failedInEncryption:
            return "Failed In Encryption"
        case .failedInDecryption:
            return "Failed In Decryption"
        case .failedInStoringPhotos:
            return "Failed In Storing Photos"
        case .failedInRetrievingPhotos:
            return "Failed In Retrieving Photos"
        case .invalidData:
            return "Invalid Data"
        case .notAuthorized:
            return "You are not authorized to see the Photos"
        case .biometryPermissionDenied:
            return "You have denied Face-ID permission. Please grant it in the App Settings."
        case .noIdentitiesEnrolled:
            return "You need to activate Face-ID for this device before using this app."
        case .failedInRetrievalOfKey:
            return "Crypto Operation Error"
        case .noStoredPhoto:
            return "No photo has taken yet"
        }
    }
}
