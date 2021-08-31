//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import Foundation
import Alamofire

/// A helper class for managing/converting `Receiver`
class ReceiverHelper {
    
    /// The singleton instance for the ReceiverHelper
    public static let shared = ReceiverHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Generate a `Receiver` model based on an APNS token
    ///
    /// - Parameter qrcode: The given QR-code containing a device name and APNS token
    /// - Returns: The resulting receiver
    public func getReceiverFromQRCode(qrcode: String) throws -> Receiver {
        guard let uri = URLComponents(string: qrcode) else {
            throw ValidationError.invalidFormat("QR-code does not contain a valid URL.")
        }
        
        guard uri.scheme == "raivo-otp" && uri.host == "add-receiver" else {
            throw ValidationError.invalidFormat("QR-code is not a from a Raivo MacOS receiver.")
        }
        
        guard let password = uri.queryItems?.first(where: { $0.name == "password" })?.value else {
            throw ValidationError.invalidFormat("QR-code does not contain a valid password")
        }
        
        guard let name = uri.queryItems?.first(where: { $0.name == "name" })?.value else {
            throw ValidationError.invalidFormat("QR-code does not contain a valid name")
        }
        
        let pushToken = String(uri.path.dropFirst())
        
        let receiver = Receiver()
        
        receiver.pushToken = pushToken
        receiver.password = password
        receiver.name = name
        
        return receiver
    }
    
    /// Check if there are any MacOS receivers currently registered
    ///
    /// - Returns: Positive if there are any receivers
    public func hasReceivers() -> Bool {
        guard let realm = RealmHelper.shared.getRealm() else {
            return false
        }
        
        return realm.objects(Receiver.self).count > 0
    }
    
    /// Send the given password to all MacOS receivers
    ///
    /// - Parameter password: The given password to send
    public func sendPassword(_ password: Password) {
        guard let realm = RealmHelper.shared.getRealm() else {
            return
        }
        
        let receivers = realm.objects(Receiver.self)
        
        guard !receivers.isEmpty else {
            return
        }
        
        var parameters: [String: [String: Any]] = [:]
        
        for receiver in receivers {
            do {
                let receiverParameters: [String: Any] = [
                    "notificationType" : 1,
                    "notificationToken" : try CryptographyHelper.shared.encrypt(password.getToken().currentPassword!, withKey: receiver.password),
                    "notificationIssuer" : try CryptographyHelper.shared.encrypt(password.issuer, withKey: receiver.password),
                    "notificationAccount" : try CryptographyHelper.shared.encrypt(password.account, withKey: receiver.password)
                ]
                
                parameters[receiver.pushToken] = receiverParameters
            } catch let error {
                log.error(error)
            }
        }
        
        AlamofireHelper.default.request(AppHelper.apnsURL, method: .post, parameters: parameters).debugLog().responseJSON { response in
            log.verbose(response)
        }
    }
    
}

/// Extend Alamofire's Request in order to log all curl commands in debug mode
extension Request {

    /// Log the current command as curl command
    public func debugLog() -> Self {
        log.verbose(self)
        
        #if DEBUG
           debugPrint(self)
        #endif
        
        return self
    }
    
}
