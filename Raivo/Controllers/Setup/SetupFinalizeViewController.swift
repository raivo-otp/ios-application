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
import Foundation

/// Persist the SetupState into e.g. the Keychain, FileStorage and UserDefaults.
class SetupFinalizeViewController: UIViewController, SetupState {
    
    /// Triggers when the user taps on the "Start" button.
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func onStart(_ sender: Any) {
        do {
            try state(self).persist()
            getAppDelegate().updateStoryboard()
        } catch let error {
            BannerHelper.error(error.localizedDescription)
        }
    }
    
}
