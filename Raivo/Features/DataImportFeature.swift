//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import ZipArchive
import RealmSwift

class DataImportFeature {
    
    private struct PasswordJson: Decodable {
        let pinned: String
        let iconValue: String
        let secret: String
        let issuer: String
        let counter: String
        let account: String
        let iconType: String
        let algorithm: String
        let kind: String
        let digits: String
        let timer: String
    }
    
    private func deleteFile(_ file: URL) {
        try? FileManager.default.removeItem(at: file)
    }
    
    private func deleteFolder(_ folder: URL) {
        try? FileManager.default.removeItem(atPath: folder.absoluteString)
    }
    
    // Attempts to read a file from a zip; returns its data on success, nil otherwise
    private func readFileFromZip(atPath zipPath: String, fileName: String, password: String) -> Data? {
        guard var destinationPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            log.error("Could not get cache directory")
            return nil
        }
        
        destinationPath = destinationPath.appendingPathComponent("raivo-otp-export")
    
        do {
            try SSZipArchive.unzipFile(
                atPath: zipPath,
                toDestination: destinationPath.path,
                overwrite: true,
                password: password
            )
        } catch let error {
            log.error("Could not unzip given ZIP archive with given password")
            log.error(error.localizedDescription)
            return nil
        }
        
        let filePath = destinationPath.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            log.error("Target file does not exist in extracted ZIP archive")
            return nil
        }
        
        var data: Data? = nil
        
        do {
            data = try Data(contentsOf: filePath)
        } catch let error {
            log.error("Could not unzip given ZIP archive with given password")
            log.error(error.localizedDescription)
            return nil
        }
    
        deleteFolder(destinationPath.absoluteURL)
        
        return data
    }
    
    private func importNewPasswords(_ data: Data) -> String? {
        let decoder = JSONDecoder()
        var passwords: [Password] = []
        var jsonData: [PasswordJson]? = nil
        
        do {
            jsonData = try decoder.decode([PasswordJson].self, from: data)
        } catch let error {
            log.error("Could not decode given JSON data")
            log.error(error.localizedDescription)
            return "Could not parse JSON data"
        }
            
        if jsonData!.isEmpty {
            return "Given JSON data is empty"
        }
            
        for (index, item) in jsonData!.enumerated() {
            let password = Password()
            password.id = password.getNewPrimaryKey() + Int64(index)
            password.issuer = item.issuer
            password.account = item.account
            password.iconType = item.iconType
            password.iconValue = item.iconValue
            password.secret = item.secret
            password.algorithm = item.algorithm
            password.digits = Int(item.digits) ?? 0
            password.kind = item.kind
            password.timer = Int(item.timer) ?? 0
            password.counter = Int(item.counter) ?? 0
            password.syncing = true
            password.synced = false
            password.pinned = Bool(item.pinned) ?? false
            
            passwords.append(password)
            log.verbose("Generated new password (ID " + String(password.id) + ") from import file.")
        }
        
        var succesfullySaved = false
        
        autoreleasepool {
            if let realm = RealmHelper.shared.getRealm() {
                try! realm.write {
                    for password in passwords {
                        realm.add(password)
                    }
                    
                    succesfullySaved = true
                }
            }
        }
        
        if !succesfullySaved {
            log.error("Could not sync imported passwords to local Realm.")
            return "Could not sync imported passwords to local Realm."
        }
        
        return nil
    }
    
    public func importArchive(privateArchiveFileURL: URL, withPassword password: String) -> String? {
        guard privateArchiveFileURL.startAccessingSecurityScopedResource() else {
            return "Permission denied"
        }
        
        defer { privateArchiveFileURL.stopAccessingSecurityScopedResource() }
        
        guard let data = readFileFromZip(atPath: privateArchiveFileURL.path, fileName: "raivo-otp-export.json", password: password) else {
            return "Not a Raivo OTP export archive"
        }
        
        if let result = importNewPasswords(data) {
            return result
        }
        
        return nil
    }
}
