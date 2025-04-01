//
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

import UIKit

extension UIViewController {
    func openUrlInApp(_ url: URL, title: String? = nil) {
        // Check if we're in a navigation controller
        if let navigationController = self.navigationController {
            // We have a navigation controller, use our in-app browser
            let browserVC = InAppBrowserViewController.create(url: url, title: title)
            
            // Set back button to "Settings"
            navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "Settings",
                style: .plain,
                target: nil,
                action: nil
            )
            
            // Push onto existing navigation stack
            navigationController.pushViewController(browserVC, animated: true)
        } else {
            // No navigation controller available, fall back to system browser
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
