//
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
