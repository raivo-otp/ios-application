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
    
    private func importNewPasswords(_ data: Data) {
        let decoder = JSONDecoder()
        do {
            let jsonData = try decoder.decode([PasswordJson].self, from: data)
            
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
        }
    }
    
    public func importArchive(archiveFileURL: URL, withPassword password: String) -> (title: String, message: String) {
        do {
            // Unzip the file
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            try SSZipArchive.unzipFile(
                atPath: archiveFileURL.path,
                toDestination: directory.path,
                overwrite: true,
                password: password
            )
            
            // Read the JSON data from the unzipped file
            let filename = directory.appendingPathComponent("raivo-otp-export.json")
            let data = try Data(contentsOf: filename)
            deleteFile(filename)
            
            // Clean up old passwords
            deleteAllPasswords()
            
            // Import new passwords
            importNewPasswords(data)
            
            // Return success message
            return ("Import Successful", "New OTPs were successfully imported from the ZIP archive.")
        } catch {
            // Return error message
            return ("Import Failed", "Failed to import OTPs from ZIP archive.")
        }
    }
}
