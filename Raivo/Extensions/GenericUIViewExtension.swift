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
