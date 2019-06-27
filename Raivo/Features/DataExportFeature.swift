//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found 
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import RealmSwift
import SSZipArchive

class DataExportFeature {
    
    public enum Result {
        case success(archive: URL)
        case failure
    }
    
    var textFile: URL? = nil
    
    var archiveFile: URL? = nil
    
    public func generateArchive(protectedWith password: String) -> Result {
        let html = getWebRepresentation()
        
        guard let text = saveWebRepresentationToFile(html) else {
            return .failure
        }
        
        guard let archive = saveWebRepresentationFileTo(webRepresentationFile: text, protectedWith: password) else {
            return .failure
        }
        
        deleteFile(text)
        
        return .success(archive: archive)
    }
    
    public func deleteArchive() {
        if let textFile = textFile {
            deleteFile(textFile)
        }
        
        if let archiveFile = archiveFile {
            deleteFile(archiveFile)
        }
    }
    
    private func deleteFile(_ file: URL) {
        try? FileManager.default.removeItem(at: file)
    }
    
    private func getWebRepresentation() -> String {
        let realm = try! Realm()
        let passwords = realm.objects(Password.self)
        
        let wrapperTemplateFile = Bundle.main.path(forResource: "all-passwords", ofType: "html")
        let passwordTemplateFile = Bundle.main.path(forResource: "single-password", ofType: "html")
        
        var wrapperText = try! String(contentsOfFile: wrapperTemplateFile!, encoding: .utf8)
        let passwordText = try! String(contentsOfFile: passwordTemplateFile!, encoding: .utf8)
        
        var passwordTextArray: [String] = []
        
        for password in passwords {
            var text = passwordText
            
            text = text.replacingOccurrences(of: "{{issuer}}", with: password.issuer)
            text = text.replacingOccurrences(of: "{{account}}", with: password.account)
            text = text.replacingOccurrences(of: "{{secret}}", with: password.secret)
            text = text.replacingOccurrences(of: "{{algorithm}}", with: password.algorithm)
            text = text.replacingOccurrences(of: "{{digits}}", with: String(password.digits))
            text = text.replacingOccurrences(of: "{{kind}}", with: password.kind)
            text = text.replacingOccurrences(of: "{{timer}}", with: String(password.timer))
            text = text.replacingOccurrences(of: "{{counter}}", with: String(password.counter))
            
            passwordTextArray.append(text)
        }
        
        wrapperText = wrapperText.replacingOccurrences(of: "{{date}}", with: Date().description)
        wrapperText = wrapperText.replacingOccurrences(of: "{{passwords}}", with: passwordTextArray.joined(separator: "<hr>"))
        
        return wrapperText
    }
    
    private func saveWebRepresentationToFile(_ text: String) -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        textFile = directory.appendingPathComponent("raivo-otp-export.html")
        
        do {
            try text.write(to: textFile!, atomically: false, encoding: .utf8)
        } catch {
            deleteFile(textFile!)
            return nil
        }
        
        return textFile
    }
    
    private func saveWebRepresentationFileTo(webRepresentationFile file: URL, protectedWith password: String) -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveFile = directory.appendingPathComponent("raivo-otp-export.zip")
        
        SSZipArchive.createZipFile(
            atPath: archiveFile!.path,
            withFilesAtPaths: [file.path],
            withPassword: password
        )
        
        return archiveFile
    }
    
}
