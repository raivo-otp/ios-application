//
//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

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
