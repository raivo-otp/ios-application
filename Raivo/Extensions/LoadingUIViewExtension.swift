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
    
    /// Show a loading animation on the right of the navbar
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
    public func dismissNavBarActivity() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    /// Dismiss the loading animation on the right of the navbar
    public func dismissNavBarActivity(_ backup: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = backup
    }

}
