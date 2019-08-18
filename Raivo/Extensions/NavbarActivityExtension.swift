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

// MARK: - Extend UIViewController with the ability to show a spinner at the top right corner
extension UIViewController {
    
    /// Show a loading animation on the right of the navbar
    ///
    /// - Returns: The bar button item that was removed
    @discardableResult
    public func displayNavBarActivity() -> UIBarButtonItem? {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        
        let backup = self.navigationItem.rightBarButtonItem
        self.navigationItem.rightBarButtonItem = item
        return backup
    }
    
    /// Dismiss the loading animation on the right of the navbar
    ///
    /// - Parameter backup: Revert to the previous bar button item
    public func dismissNavBarActivity(_ backup: UIBarButtonItem? = nil) {
        self.navigationItem.rightBarButtonItem = backup
    }

}
