//
//  CryptoManager.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import CryptoKit
import Security

final class CryptoManager {
    let legacyCrypto: LegacyCryptoProtocol
    static let shared = CryptoManager(legacyCrypto: LegacyCrypto.shared)
    
    init(legacyCrypto: LegacyCryptoProtocol) {
        self.legacyCrypto = legacyCrypto
    }
    
    func encryptPhoto(_ data: Data) throws -> Data {
        if #available(iOS 13.0, *) {
            do {
                return try encryptPhotoUsingCryptoKit(data)
            } catch {
                throw IDError.failedInEncryption
            }
        } else {
            do {
                return try legacyCrypto.encryptPhotoLegacy(data)
            } catch {
                throw IDError.failedInEncryption
            }
        }
    }

    func decryptPhoto(_ encryptedData: Data) throws -> Data? {
        if #available(iOS 13.0, *) {
            do {
                return try decryptPhotoUsingCryptoKit(encryptedData)
            } catch {
                throw IDError.failedInDecryption
            }
        } else {
            do {
                return try legacyCrypto.decryptPhotoLegacy(encryptedData)
            } catch {
                throw IDError.failedInDecryption
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func encryptPhotoUsingCryptoKit(_ data: Data) throws -> Data {
        let keyData = try SymmetricKeyProvider.shared.retrieveSymmetricKeyData()
        let key = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.seal(data, using: key)
        
        // Convert nonce to Data
        let nonceData = Data(sealedBox.nonce)
        
        // Combine nonce, ciphertext, and tag
        let combinedData = nonceData + sealedBox.ciphertext + sealedBox.tag
        return combinedData
    }

    @available(iOS 13.0, *)
    private func decryptPhotoUsingCryptoKit(_ encryptedData: Data) throws -> Data {
        let keyData = try SymmetricKeyProvider.shared.retrieveSymmetricKeyData()
        let key = SymmetricKey(data: keyData)
        // Extract the nonce, ciphertext, and tag
        let nonceSize = 12 // AES.GCM.Nonce size in bytes
        let tagSize = 16   // AES-GCM authentication tag size in bytes
        
        guard encryptedData.count >= nonceSize + tagSize else {
            throw IDError.failedInDecryption
        }
        
        let nonceData = encryptedData.subdata(in: 0..<nonceSize)
        let ciphertext = encryptedData.subdata(in: nonceSize..<(encryptedData.count - tagSize))
        let tagData = encryptedData.subdata(in: (encryptedData.count - tagSize)..<encryptedData.count)
        
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tagData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }
}
