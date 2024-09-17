//
//  StorageManager.swift
//  IdFramework
//
//  Created by Abbas Sabeti on 17.09.24.
//

import Foundation

final class StorageManager {
    
    static let shared = StorageManager()
    private let directoryURL: URL

    init(directoryURL: URL? = nil) {
        if let directoryURL = directoryURL {
            self.directoryURL = directoryURL
        } else {
            self.directoryURL = Self.getPrivateDirectory()
        }
    }

    func saveEncryptedImage(_ data: Data, fileName: String) throws {
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw IDError.failedInStoringPhotos
        }
    }

    func retrieveAllEncryptedImages() throws -> [(fileName: String, data: Data)]? {
        let directoryURL = directoryURL
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
            var dataList = [(fileName: String, data: Data)]()
            
            for fileURL in fileURLs {
                if let data = try? Data(contentsOf: fileURL) {
                    let fileName = fileURL.lastPathComponent
                    dataList.append((fileName: fileName, data: data))
                }
            }
            
            return dataList
        } catch {
            throw IDError.failedInRetrievingPhotos
        }
    }
    
    private static func getPrivateDirectory() -> URL {
        let fileManager = FileManager.default
        let libraryDir = try! fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let privateDir = libraryDir.appendingPathComponent("Private", isDirectory: true)
        
        if !fileManager.fileExists(atPath: privateDir.path) {
            try! fileManager.createDirectory(at: privateDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return privateDir
    }
}
