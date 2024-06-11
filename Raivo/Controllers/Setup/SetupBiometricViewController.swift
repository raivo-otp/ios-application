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

/// Allow the user to enable TouchID or FaceID unlock.
class SetupBiometricViewController: UIViewController, SetupState {
    
    /// A reference to the title label.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// A reference to the description label.
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /// A reference to the dismiss button.
    @IBOutlet weak var dismissButton: UIButton!
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BiometricHelper.shared.type() == .face {
            navigationItem.title = "FaceID"
            titleLabel.text = "Configure FaceID unlock."
            descriptionLabel.text = "Biometry allows you to unlock Raivo with FaceID, instead of your passcode."
            dismissButton.setTitle("I don't want to use FaceID unlock.", for: .normal)
        } else {
            navigationItem.title = "TouchID"
            titleLabel.text = "Configure TouchID unlock."
            descriptionLabel.text = "Biometry allows you to unlock Raivo with TouchID, instead of your passcode."
            dismissButton.setTitle("I don't want to use TouchID unlock.", for: .normal)
        }
    }
    
    /// Triggers when the user taps on the "I don't want to use biometric unlock" button.
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func dismissBiometricUnlock(_ sender: Any) {
        state(self).biometric = false
        performSegue(withIdentifier: "SetupFinalizeSegue", sender: sender)
    }
    
    /// Triggers when the user taps on the "Enable" button.
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func enableBiometricUnlock(_ sender: Any) {
        state(self).biometric = true
        performSegue(withIdentifier: "SetupFinalizeSegue", sender: sender)
    }
    
}
