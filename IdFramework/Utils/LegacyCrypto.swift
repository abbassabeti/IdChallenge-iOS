//
//  LegacyCrypto.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import Foundation
import CommonCrypto

protocol LegacyCryptoProtocol {
    func encryptPhotoLegacy(_ data: Data) throws -> Data
    func decryptPhotoLegacy(_ encryptedData: Data) throws -> Data
}

final class LegacyCrypto: LegacyCryptoProtocol {
    static let shared = LegacyCrypto()

    func encryptPhotoLegacy(_ data: Data) throws -> Data {
        let keyData = try SymmetricKeyProvider.shared.retrieveSymmetricKeyData()
        let keyLength = size_t(kCCKeySizeAES256)
        let ivSize = kCCBlockSizeAES128
        var iv = Data(count: ivSize)
        let result = iv.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, ivSize, $0.baseAddress!)
        }
        if result != errSecSuccess {
            throw IDError.failedInEncryption
        }
        
        let cryptLength = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, keyLength,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            cryptBytes.baseAddress, cryptLength,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }
        
        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            // Prepend the IV to the encrypted data
            let encryptedData = iv + cryptData
            return encryptedData
        } else {
            throw IDError.failedInEncryption
        }
    }
    
    func decryptPhotoLegacy(_ encryptedData: Data) throws -> Data {
        let keyData = try SymmetricKeyProvider.shared.retrieveSymmetricKeyData()
        let keyLength = size_t(kCCKeySizeAES256)
        let ivSize = kCCBlockSizeAES128
        
        guard encryptedData.count > ivSize else {
            throw IDError.invalidData
        }
        
        let iv = encryptedData.subdata(in: 0..<ivSize)
        let cipherData = encryptedData.subdata(in: ivSize..<encryptedData.count)
        
        let cryptLength = size_t(cipherData.count)
        var decryptedData = Data(count: cryptLength)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = decryptedData.withUnsafeMutableBytes { decryptedBytes in
            cipherData.withUnsafeBytes { cipherBytes in
                iv.withUnsafeBytes { ivBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, keyLength,
                            ivBytes.baseAddress,
                            cipherBytes.baseAddress, cipherData.count,
                            decryptedBytes.baseAddress, cryptLength,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        if cryptStatus == CCCryptorStatus(kCCSuccess) {
            decryptedData.removeSubrange(numBytesDecrypted..<decryptedData.count)
            return decryptedData
        } else {
            throw IDError.failedInDecryption
        }
    }
}
