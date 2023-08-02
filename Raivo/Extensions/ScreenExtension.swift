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
import SwiftUI

// MARK: - Extend UIScreen with the ability to change the brightness in an animated way
extension UIScreen {

    /// The size of a brightness change step
    private static let step: CGFloat = 0.05
    
    /// Change the screen brightness in an animated way
    ///
    /// - Parameter to: Target brightness percentage
    static func animateBrightness(to value: CGFloat) {
        guard abs(UIScreen.main.brightness - value) > step else { return }

        let delta = UIScreen.main.brightness > value ? -step : step

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            UIScreen.main.brightness += delta
            animateBrightness(to: value)
        }
    }
}
