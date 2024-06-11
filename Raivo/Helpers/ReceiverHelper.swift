//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

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
    public func getReceiverFromQRCode(_ qrcode: String) throws -> Receiver {
        guard let uri = URLComponents(string: qrcode) else {
            throw ValidationError.invalidFormat("QR-code does not contain a valid URL.")
        }
        
        guard uri.scheme == "raivo-otp" && uri.host == "add-receiver" else {
            throw ValidationError.invalidFormat("QR-code is not a from a Raivo MacOS receiver.")
        }
        
        guard let password = uri.queryItems?.first(where: { $0.name == "password" })?.value else {
            throw ValidationError.invalidFormat("QR-code does not contain a valid password.")
        }
        
        guard let name = uri.queryItems?.first(where: { $0.name == "name" })?.value else {
            throw ValidationError.invalidFormat("QR-code does not contain a valid name.")
        }
        
        let pushToken = String(uri.path.dropFirst())
        
        let receiver = Receiver()
        
        receiver.pushToken = pushToken
        receiver.password = password
        receiver.name = name
        
        return receiver
    }
    
    /// Validate a `Receiver` QR code
    ///
    /// - Parameter qrcode: The given QR-code containing a device name and APNS token
    /// - Returns: Positive if the given QR code is valid
    public func isValid(_ qrcode: String) -> Bool {
        guard let _ = try? getReceiverFromQRCode(qrcode) else {
            return true
        }
        
        return false
    }
    
    /// Check if there are any MacOS receivers currently registered
    ///
    /// - Returns: Positive if there are any receivers
    public func hasReceivers() -> Bool {
        guard let realm = try? RealmHelper.shared.getRealm() else {
            return false
        }
        
        return realm.objects(Receiver.self).count > 0
    }
    
    /// Send the given password to all MacOS receivers
    ///
    /// - Parameter password: The given password to send
    public func sendPassword(_ password: Password) {
        guard let realm = try? RealmHelper.shared.getRealm() else {
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
