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

/// An object used to define (alternate) app icons.
class AppIconObject {
    
    /// The key (filename without extension) of the app icon
    var key: String
    
    /// The name/title describing the app icon
    var name: String
    
    /// If this icon is the primary icon of the app
    var isPrimary: Bool
    
    /// Initialize an app icon object with a key/filename and a title
    ///
    /// - Parameter key: The key (filename without extension) of the app icon
    /// - Parameter name: The name/title describing the app icon
    /// - Parameter isPrimary: True if this icon is the primary icon of the app
    init(_ key: String, _ name: String, _ isPrimary: Bool = false) {
        self.key = key
        self.name = name
        self.isPrimary = isPrimary
    }
    
    /// Get the alternate key to set for this icon object
    ///
    /// - Returns: The image source key or nil if this is the primary icon
    /// - Note: The alternate key is nil for the primary icon (instead if the UIImage source)
    func getAlternateKey() -> String? {
        return isPrimary ? nil : key
    }
    
}
