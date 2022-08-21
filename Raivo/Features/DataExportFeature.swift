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

import Foundation
import UIKit
import RealmSwift
import ZipArchive
import EFQRCode
import HTMLString

class DataExportFeature {
    
    public enum Representation {
        case html
        case json
    }
    
    public enum Result {
        case success(archive: URL)
        case failure
    }
    
    private var archiveFile: URL? = nil
    
    public func generateArchive(protectedWith password: String) -> Result {
        let html = getHTMLRepresentation()
        let json = getJSONRepresentation()
        
        guard let htmlPath = saveRepresentationToFile(html, .html) else {
            return .failure
        }
        
        guard let jsonPath = saveRepresentationToFile(json, .json) else {
            return .failure
        }
        
        guard let archive = saveToArchive(representationFiles: [htmlPath, jsonPath], protectedWith: password) else {
            return .failure
        }
        
        deleteFile(htmlPath)
        deleteFile(jsonPath)
        
        return .success(archive: archive)
    }
    
    public func deleteArchive() {
        if let archiveFile = archiveFile {
            deleteFile(archiveFile)
        }
    }
    
    private func deleteFile(_ file: URL) {
        try? FileManager.default.removeItem(at: file)
    }
    
    private func getHTMLRepresentation() -> String {
        let possiblePasswords = autoreleasepool { () -> Results<Password>? in
            if let realm = RealmHelper.shared.getRealm() {
                let sortProperties = [SortDescriptor(keyPath: "issuer"), SortDescriptor(keyPath: "account")]
                return realm.objects(Password.self).filter("deleted == 0").sorted(by: sortProperties)
            }
            
            return nil
        }
        
        guard let passwords = possiblePasswords else {
            return "An error occurred during the export. Please try again!"
        }

        let wrapperTemplateFile = Bundle.main.path(forResource: "all-passwords", ofType: "html")
        let passwordTemplateFile = Bundle.main.path(forResource: "single-password", ofType: "html")
        
        var wrapperText = try! String(contentsOfFile: wrapperTemplateFile!, encoding: .utf8)
        let passwordText = try! String(contentsOfFile: passwordTemplateFile!, encoding: .utf8)
        
        var passwordTextArray: [String] = []
        
        for password in passwords {
            var text = passwordText
            
            text = text.replacingOccurrences(of: "{{issuer}}", with: password.issuer.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{account}}", with: password.account.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{secret}}", with: password.secret.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{algorithm}}", with: password.algorithm.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{digits}}", with: String(password.digits).addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{kind}}", with: password.kind.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{timer}}", with: String(password.timer).addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{counter}}", with: String(password.counter).addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{iconType}}", with: password.iconType.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{iconValue}}", with: password.iconValue.addingASCIIEntities())
            text = text.replacingOccurrences(of: "{{icon}}", with: getIconHTML(password))
            text = text.replacingOccurrences(of: "{{qrcode}}", with: getQuickResponseCodeHTML(password))
            
            passwordTextArray.append(text)
        }
        
        wrapperText = wrapperText.replacingOccurrences(of: "{{date}}", with: Date().description)
        wrapperText = wrapperText.replacingOccurrences(of: "{{passwords}}", with: passwordTextArray.joined(separator: "<hr>"))
        
        return wrapperText
    }

    private func getIconHTML(_ password: Password) -> String {
        guard let url = password.getIconURL()?.absoluteString else {
            return "URI could not be generated from icon type and value."
        }
        
        return "<img src='" + url + "' height=200 width=200 />"
    }
    
    private func getQuickResponseCodeHTML(_ password: Password) -> String {
        guard let qrcodeImage = EFQRCode.generate(
            for: try! password.getToken().toCompatibleURL().absoluteString + "&secret=" + password.secret.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
            size: EFIntSize(width: 300, height: 300)
        ) else {
            return "QR code could not be generated."
        }
        
        guard let qrcodeData = UIImage(cgImage: qrcodeImage).pngData() else {
            return "PNG data could not be extracted from QR code."
        }
        
        return "<img src='data:image/png;base64," + qrcodeData.base64EncodedString() + "' height=200 width=200 />"
    }
    
    private func getJSONRepresentation() -> String {
        let possiblePasswords = autoreleasepool { () -> Array<Password>? in
            if let realm = RealmHelper.shared.getRealm() {
                let sortProperties = [SortDescriptor(keyPath: "issuer"), SortDescriptor(keyPath: "account")]
                return Array(realm.objects(Password.self).filter("deleted == 0").sorted(by: sortProperties))
            }
            
            return nil
        }
        
        guard let passwords = possiblePasswords else {
            return "{\"message\": \"Could not retrieve OTPs from Realm\"}"
        }
        
        guard let json = try? JSONSerialization.data(withJSONObject: passwords.map { $0.getExportFields() }, options: []) else {
            return "{\"message\": \"Could not convert OTPs to JSON\"}"
        }
        
        if let result = String(data: json, encoding: String.Encoding.utf8) {
            return result
        }
        
        return "{\"message\": \"Could not convert JSON to a string\"}"
    }
    
    private func saveRepresentationToFile(_ text: String, _ type: Representation) -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let folderPath = directory.appendingPathComponent("raivo-otp-export")
        
        do {
            try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        
        let filePath = folderPath.appendingPathComponent("raivo-otp-export." + getFileExtension(type))
        
        do {
            try text.write(to: filePath, atomically: false, encoding: .utf8)
        } catch {
            deleteFile(filePath)
            return nil
        }
        
        return filePath
    }
    
    private func saveToArchive(representationFiles files: [URL], protectedWith password: String) -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveFile = directory.appendingPathComponent("raivo-otp-export.zip")
        
        let inputFilesPath = files.first!.path.split(separator: "/").dropLast(1).map(String.init).joined(separator: "/")
        
        SSZipArchive.createZipFile(
            atPath: archiveFile!.path,
            withContentsOfDirectory: inputFilesPath,
            keepParentDirectory: false,
            compressionLevel: 0,
            password: password,
            aes: true
        )
        
        return archiveFile
    }
    
    private func getFileExtension(_ type: Representation) -> String {
        switch type {
        case .html:
            return "html"
        case .json:
            return "json"
        }
    }
}
