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

/// This controller allows users to setup their passcode
class SetupPasscodeViewController: UIViewController, UIPasscodeFieldDelegate, SetupState {
    
    /// If the user confirmed the password, this var will contain the confirmed password
    public var confirmation: String? = nil
    
    /// A reference to the passcode field
    @IBOutlet weak var passcodeField: UIPasscodeField!
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
                
        passcodeField.delegate = self
        passcodeField.layoutIfNeeded()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passcodeField.becomeFirstResponder()
    }

    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
    }
    
    /// Notifies the view controller that its view was removed from a view hierarchy.
    ///
    /// - Parameter animated: If true, the disappearance of the view was animated.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if confirmation != nil {
            passcodeField.reset()
        }
    }
    
    /// Called if the user finished entering the passcode.
    ///
    /// - Parameter passcode: The passcode that the user entered.
    func onPasscodeComplete(passcode: String) {
        // Allow UIPasscodeField to finish animations before continueing
        DispatchQueue.main.async {
            self.onContinue()
        }
    }
    
    /// If the passcode changes, set the confirmation to nil.
    ///
    /// - Parameter passcode: The new (possibly incomplete) passcode.
    func onPasscodeChange(passcode: String) {
        confirmation = nil
    }
    
    /// On continue is called by various triggers and should try to continue to the next setup stage
    func onContinue() {
        let passcode = passcodeField.current
        
        guard confirmation != nil else {
            return performSegue(withIdentifier: "SetupPasscodeConfirmationSegue", sender: nil)
        }
        
        guard passcode == confirmation else {
            confirmation = nil
            passcodeField.reset()
            passcodeField.becomeFirstResponder()
            
            return BannerHelper.error("The passcode and confirmation do not match", icon: "👮")
        }
        
        do {
            state(self).encryptionKey = try CryptographyHelper.shared.derive(passcode, withSalt: state(self).password!)
        } catch let error {
            return BannerHelper.error(error.localizedDescription)
        }
        
        passcodeField.reset()
        passcodeField.layoutIfNeeded()
        
        if StorageHelper.shared.canAccessSecrets() {
            performSegue(withIdentifier: "SetupBiometricSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "SetupSkipToFinalizeSegue", sender: nil)
        }
    }
    
    /// Prepare for the setup encryption segue
    ///
    /// - Parameter segue: The segue object containing information about the view controllers involved in the segue.
    /// - Parameter sender: The object that initiated the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "SetupPasscodeConfirmationSegue" {
            if let destination = segue.destination as? SetupPasscodeConfirmationViewController {
                destination.sendingController = self
            }
        }
    }
}
