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
