//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit

// MARK: - Extend UIViewController with the ability to load XIB files into a view
extension UIViewController {
    
    /// Load a `.xib` file into a UIView class
    ///
    /// - Parameter identifier: The name of the `.xib` file
    /// - Returns: The `.xib` file wrapped in a `UIView`
    public func loadXIBAsUIView(_ identifier: String) -> UIView {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        return (nib.instantiate(withOwner: nil, options: nil)[0] as? UIView)!
    }

}
