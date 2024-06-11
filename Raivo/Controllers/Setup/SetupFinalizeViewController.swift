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
import Foundation

/// Persist the SetupState into e.g. the Keychain, FileStorage and UserDefaults.
class SetupFinalizeViewController: UIViewController, SetupState {
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        // The setup is done, prevent back swiping
        navigationItem.hidesBackButton = true
    }
    
    /// Triggers when the user taps on the "Start" button.
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func onStart(_ sender: Any) {
        do {
            try state(self).persist()
            getAppDelegate().updateStoryboard()
        } catch let error {
            BannerHelper.shared.error("Setup failed", error.localizedDescription, wrapper: view)
        }
    }
    
}
