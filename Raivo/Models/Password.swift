//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import RealmSwift
import OneTimePassword

/// A password object is basically just a One-Time-Password.
///
/// - Note: This was implemented as per Google guidelines:
///         https://github.com/google/google-authenticator/wiki/Key-Uri-Format
class Password: Object {
    
    public static let TABLE = "Password"
        
    public struct SyncErrorTypes {
        static let INSERT = "insert"
        static let UPDATE = "update"
        static let DELETE = "delete"
    }
    
    private var cachedToken: Token? = nil
    
    @objc dynamic var id = Int64(0)
    
    @objc dynamic var kind = PasswordKindFormOption.OPTION_DEFAULT.value
    
    @objc dynamic var issuer = ""
    
    @objc dynamic var account = ""
    
    @objc dynamic var secret = ""
    
    @objc dynamic var algorithm = PasswordAlgorithmFormOption.OPTION_DEFAULT.value
    
    @objc dynamic var digits = PasswordDigitsFormOption.OPTION_DEFAULT.value
    
    @objc dynamic var iconType = ""
    
    @objc dynamic var iconValue = ""
    
    // Required if HOTP
    @objc dynamic var counter: Int = 0
    
    // Required if TOTP
    @objc dynamic var timer = 30
    
    @objc dynamic var deleted = false
    
    @objc dynamic var syncing = false
    
    @objc dynamic var synced = false
    
    // At what action did the sync fail (INSERT, UPDATE...)
    @objc dynamic var syncErrorType: String?
    
    // What was the error syncing message
    @objc dynamic var syncErrorDescription: String?

    override static func primaryKey() -> String? {
        return "id"
    }
    
    public func getNewPrimaryKey() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    public func getRemotePrimaryKey() -> String {
        return Password.TABLE + "-" + String(id)
    }
    
    public func getToken(_ recache: Bool = false) -> Token {
        if cachedToken == nil || recache {
            cachedToken = TokenHelper.getTokenFromPassword(password: self)
        }
        
        return cachedToken!
    }
    
    public func getIconURL() -> URL? {
        switch iconType {
        case PasswordIconTypeFormOption.OPTION_RAIVO_REPOSITORY.value:
            return URL(string: AppHelper.iconsURL + self.iconValue)
        default:
            return nil
        }
    }
    
    public func getExportFields() -> [String: String] {
        return [
            "issuer": issuer,
            "account": account,
            "secret": secret,
            "algorithm": algorithm,
            "digits": String(digits),
            "kind": kind,
            "timer": String(timer),
            "counter": String(counter)
        ]
    }

}
