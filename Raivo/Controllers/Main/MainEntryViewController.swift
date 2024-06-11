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

/// This ViewController is basically a tabbar controller, it can be managed using the storyboard.
class MainEntryViewController: UITabBarController, UITabBarControllerDelegate {
    
    var handlingTappedAttempt: Bool = false
    
    /// Triggers after the view was parsed
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        NotificationHelper.shared.listen(to: UIApplication.didBecomeActiveNotification, distinctBy: id(self)) { (notification) in
            AddTappedUriFeature.shared.notify(on: self)
        }
        
        AddTappedUriFeature.shared.notify(on: self)
    }
    
    /// Notifies the view controller that its view was removed from a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationHelper.shared.discard(UIApplication.didBecomeActiveNotification, byDistinctName: id(self))
    }
    
    /// On tab bar item change, run custom functionality
    /// 
    /// - Note In this case, custom search functionality was added
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if (viewController.restorationIdentifier == "SearchStubController") {
            
            // Pop all the way back to one of the tabs (e.g. from CreatePassword to Passwords)
            if let navigationController = (viewControllers![0] as? UINavigationController) {
                navigationController.popToViewController(navigationController.viewControllers[0], animated: true)
            }
            
            if (selectedIndex == 0) {
                log.verbose("SearchStubController selectedIndex = 0")
                // PasswordsViewController is active, show search bar
                let passwordsController = (selectedViewController!.children.last as! MainPasswordsViewController)
                passwordsController.showSearchBar()
            } else {
                log.verbose("SearchStubController selectedIndex != 0")
                // Show PasswordsViewController instead of SearchViewController
                selectedIndex = 0
                
                // PasswordsViewController is not yet active, notify that it has to show the search bar asap
                let passwordsController = (selectedViewController!.children.last as! MainPasswordsViewController)
                passwordsController.startSearching = true
            }
            
            return false
        }
        
        return true
    }
    
}
