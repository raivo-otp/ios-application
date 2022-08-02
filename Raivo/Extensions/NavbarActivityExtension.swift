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
import UIKit

// MARK: - Extend UIViewController with the ability to show a spinner at the top right corner
extension UIViewController {
    
    /// Show a loading animation on the right of the navbar
    ///
    /// - Returns: The bar button item that was removed
    @discardableResult
    public func displayNavBarActivity() -> UIBarButtonItem? {
        let indicator = UIActivityIndicatorView(style: .medium)
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
