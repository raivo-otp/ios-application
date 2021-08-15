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
        let receiver = Receiver()
        
        if !qrcode.starts(with: "RaivoMacOSReceiver:") {
            throw ValidationError.invalidFormat("Not a Raivo OTP MacOS Receiver QR-code.")
        }
        
        let parsed = qrcode.dropFirst(19)
        
        let pushToken = parsed.split(separator: ":", maxSplits: 1).first!
        let name = parsed.split(separator: ":", maxSplits: 1).last!
         
        receiver.id = receiver.getNewPrimaryKey()
        receiver.pushToken = String(pushToken)
        receiver.name = String(name)

        return receiver
    }
    
    public func sendPassword(_ password: Password) {
        guard let realm = RealmHelper.shared.getRealm() else {
            return
        }
        
        let receivers = realm.objects(Receiver.self)
        
        guard !receivers.isEmpty else {
            return
        }
        
        var deviceTokens: [String] = []
        
        for receiver in receivers {
            deviceTokens.append(receiver.pushToken)
        }
        
        let parameters: [String: Any] = [
            "deviceTokens" : deviceTokens,
            "raivoType" : 1,
            "raivoToken" : password.getToken().currentPassword!,
            "raivoIssuer" : password.issuer,
            "raivoAccount" : password.account
        ]
        
        AlamofireHelper.default.request(AppHelper.apnsURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
        }
    }
    
}
