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
import UIKit

// MARK: - Extend UIColor with custom colors
extension UIColor {
    
    public static func getLabel() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        }
        
        if let color = UIColor(named: "color-label") {
            return color
        }
        
        return UIColor.black
    }
    
    public static func getSecondaryLabel() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        }
        
        if let color = UIColor(named: "color-secondary-label") {
            return color
        }
        
        return UIColor(red: 60, green: 60, blue: 67, alpha: 1)
    }
    
    public static func getTintRed() -> UIColor {
        return UIColor(named: "color-tint-red")!
    }

    public static func getTintBlue() -> UIColor {
        return UIColor(named: "color-tint-blue")!
    }

    public static func getBackgroundOpaque() -> UIColor {
        return UIColor(named: "color-background-opaque")!
    }

    public static func getBackgroundTransparent() -> UIColor {
        return UIColor(named: "color-background-transparent")!
    }
    
    public static func getBackgroundEureka() -> UIColor {
        return UIColor(named: "color-background-eureka")!
    }
}
