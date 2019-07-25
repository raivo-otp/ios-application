//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit

/// This ViewController is basically a tabbar controller, it can be managed using the storyboard.
class MainEntryViewController: UITabBarController, UITabBarControllerDelegate {
    
    /// Triggers after the view was parsed
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    /// On tab bar item change, run custom functionality
    /// In this case, custom search functionality was added
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if (viewController.restorationIdentifier == "SearchViewController") {
            
            // Pop all the way back to one of the tabs (e.g. from CreatePassword to Passwords)
            if let navigationController = (viewControllers![0] as? UINavigationController) {
                navigationController.popToViewController(navigationController.viewControllers[0], animated: true)
            }
            
            if (selectedIndex == 0) {
                log.verbose("SearchViewController selectedIndex = 0")
                // PasswordsViewController is active, show search bar
                let passwordsController = (selectedViewController!.children[0] as! MainPasswordsViewController)
                passwordsController.showSearchBar()
            } else {
                log.verbose("SearchViewController selectedIndex != 0")
                // Show PasswordsViewController instead of SearchViewController
                selectedIndex = 0
                
                // PasswordsViewController is not yet active, notify that it has to show the search bar asap
                let passwordsController = (selectedViewController!.children[0] as! MainPasswordsViewController)
                passwordsController.startSearching = true
            }
            
            return false
        }
        
        return true
    }
    
}
