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

import RealmSwift
import OneTimePassword
import Foundation

/// A receiver object is e.g. a Macbook that can receive an encrypted One-Time-Password
class Receiver: Object, Identifiable {
    
    public static let TABLE = "Receiver"
        
    @objc dynamic var pushToken = ""
    
    @objc dynamic var password = ""
    
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "pushToken"
    }
    
    public func getExportFields() -> [String: String] {
        return [
            "pushToken": pushToken,
            "password": password,
            "name": name
        ]
    }

}
