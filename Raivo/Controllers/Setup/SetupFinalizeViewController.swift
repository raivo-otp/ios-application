//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
//

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
            BannerHelper.shared.error("Error", error.localizedDescription, wrapper: view)
        }
    }
    
}
