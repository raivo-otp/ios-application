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
    
    private func deleteAllPasswords() {
        if let realm = RealmHelper.shared.getRealm() {
            let passwords = realm.objects(Password.self)
            for password in passwords {
                try? realm.write {
                    password.deleted = true
                }
            }
        }
    }
    
    // Attempts to read a file from a zip; returns its data on success, nil otherwise
    private func readFileFromZip(atPath zipPath: String, fileName: String, password: String) -> Data? {
        guard let destinationPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
    
        do {
            try SSZipArchive.unzipFile(
                atPath: zipPath,
                toDestination: destinationPath.path,
                overwrite: true,
                password: password
            )
            
            let filePath = destinationPath.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: filePath.path) {
                let data = try Data(contentsOf: filePath)
                deleteFile(filePath)
                return data
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // Imports passwords from file data; returns nil on success, error string otherwise
    private func importNewPasswords(_ data: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let jsonData = try decoder.decode([PasswordJson].self, from: data)
            
            if jsonData.isEmpty {
                return "JSON file in ZIP contains no passwords."
            }
            
            for item in jsonData {
                
                // Construct a password
                let password = Password()
                password.id = password.getNewPrimaryKey()
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
                
                // Store the password
                if let realm = RealmHelper.shared.getRealm() {
                    try realm.write {
                        realm.add(password)
                    }
                }
            }
        } catch {
            print("error importing passwords")
            return "Invalid JSON file in ZIP."
        }
        
        return nil
    }
    
    public func importArchive(archiveFileURL: URL, withPassword password: String, shouldDeleteOldPasswords: Bool = false) -> (title: String, message: String) {
        
        func myError(_ message: String) -> (title: String, message: String) {
            return ("Import Failed", message)
        }
        
        // Password validation
        if SSZipArchive.isPasswordValidForArchive(atPath: archiveFileURL.path, password: password, error: nil) == false {
            return myError("Password incorrect.")
        }
        
        // Load file from zip
        guard let data = readFileFromZip(atPath: archiveFileURL.path, fileName: "raivo-otp-export.json", password: password) else {
            return myError("Not a Raivo OTP export archive.")
        }
        
        // Clean up old passwords
        if shouldDeleteOldPasswords {
            deleteAllPasswords()
        }
        
        // Import new passwords
        if let result = importNewPasswords(data) {
            return myError(result)
        }
        
        // Return success message
        return ("Import Successful", "New OTPs were successfully imported from the ZIP archive.")
    }
}
