//
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
import StoreKit

// MARK: - Extend SKProduct with the ability to initialize 'stub' classes
extension SKProduct {

    /// Change the screen brightness in an animated way
    ///
    /// - Parameter to: Target brightness percentage
    convenience init(identifier: String, title: String, description: String, price: Decimal) {
        self.init()
        self.setValue(identifier, forKey: "productIdentifier")
        self.setValue(title, forKey: "localizedTitle")
        self.setValue(description, forKey: "localizedDescription")
        self.setValue(price, forKey: "price")
        self.setValue(Locale(identifier: "en_US"), forKey: "priceLocale")
    }
    
}
