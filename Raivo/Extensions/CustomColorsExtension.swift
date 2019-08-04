//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
//

import Foundation
import UIKit

// MARK: - Extend UIColor with custom colors
extension UIColor {
    
    public static func getLabel(_ darkMode: Bool = false) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else if darkMode {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    public static func getSecondaryLabel(_ darkMode: Bool = false) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else if darkMode {
            return UIColor(hex: "ebebf5")
        } else {
            return UIColor(hex: "3c3c43")
        }
    }
    
    public static func getTintRed(_ darkMode: Bool = false) -> UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "color-tint-red")!
        } else if darkMode {
            return UIColor(red: 255, green: 62, blue: 74, alpha: 1.0)
        } else {
            return UIColor(hex: "#e80d33")
        }
    }

    public static func getTintBlue(_ darkMode: Bool = false) -> UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "color-tintRed-blue")!
        } else if darkMode {
            return UIColor(red: 20, green: 142, blue: 255, alpha: 1.0)
        } else {
            return UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }

    public static func getBackgroundOpaque(_ darkMode: Bool = false) -> UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "color-background-opaque")!
        } else if darkMode {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }

    public static func getBackgroundTransparent(_ darkMode: Bool = false) -> UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "color-background-transparent")!
        } else if darkMode {
            return UIColor(hex: "#131313").withAlphaComponent(0.95)
        } else {
            return UIColor(hex: "#ececec").withAlphaComponent(0.95)
        }
    }
}
