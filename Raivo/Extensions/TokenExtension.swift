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
import OneTimePassword
import Base32

// MARK: - Extend OneTimePasswords' Token class with the ability to generate URLs that are widely comptabile in the 'OTP scene'
extension Token {

    /// Serialize a token to a URL in a way that it's compatible across other OTP apps
    ///
    /// - Returns: The URL object
    /// - Note:
    ///     Apparently the name of the OTP should be included in the path of the URL. The OneTimePassword dependency
    ///     doesn't do this by default. Check issue #98 on GitHub for more infirmation.
    ///     https://github.com/raivo-otp/ios-application/issues/98
    /// - Note:
    ///     Changes:  "otpauth://totp/john.doe@outlook.com?algorithm=SHA1&digits=6&issuer=LinkedIn&period=30"
    ///     To: "otpauth://totp/LinkedIn:john.doe@outlook.com?algorithm=SHA1&digits=6&issuer=LinkedIn&period=30"
    ///
    func toCompatibleURL() throws -> URL {
        let url = try toURL()
        
        let encodedIssuer = self.issuer.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let encodedName = self.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        
        var compatible = URLComponents(string: url.absoluteString)
        compatible!.path = "/\(encodedIssuer):\(encodedName)"
        
        return try compatible!.asURL()
    }
    
}
