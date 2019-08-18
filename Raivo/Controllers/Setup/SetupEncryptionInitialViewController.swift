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

/// Enable the user to set the master password (initial, not confirm)
class SetupEncryptionInitialViewController: UIViewController, UITextFieldDelegate {

    /// The current state of the setup
    public var state: SetupStateObject? = nil
    
    /// If the user confirmed the password, this var will contain the confirmed password
    public var confirmation: String? = nil
    
    /// True if a user has setup Raivo before, and is recovering data now
    private var recoveryMode: Bool = false
    
    /// A reference to the title label of the view
    @IBOutlet weak var viewTitle: UILabel!
    
    /// A reference to the description label of the view
    @IBOutlet weak var viewDescription: UILabel!
    
    /// A reference to the password field
    @IBOutlet weak var viewEncryptionPassword: UITextField!

    //// A reference the the "I forgot my password" button
    @IBOutlet weak var forgotView: UIButton!
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewEncryptionPassword.delegate = self
        adjustViewToKeyboard()

        if recoveryMode {
            viewTitle.text = "Load data from storage provider."
            viewDescription.text = "You've used Raivo before. Enter the recovery password you took note of back then."
            forgotView.isHidden = false
        }
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if confirmation == nil {
            viewEncryptionPassword.becomeFirstResponder()
        }
    }
    
    /// On 'return' on the keyboard, perform the same action as the "continue" button.
    ///
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: Positive if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "SetupEncryptionConfirmationSegue", sender: textField)
        return false
    }
    
    /// If the password changes, set the confirmation to nil
    ///
    /// - Parameter textField: The text field containing the text.
    /// - Parameter range: The range of characters to be replaced.
    /// - Parameter string: The replacement string for the specified range.
    /// - Returns: Positive if the specified text range should be replaced; otherwise, false to keep the old text.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        confirmation = nil
        return true
    }
    
    /// Triggers when the continue button is tapped
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func onContinue(_ sender: Any) {
        guard viewEncryptionPassword.text?.length ?? 0 >= 8 else {
            viewEncryptionPassword.becomeFirstResponder()
            return BannerHelper.error("The minimum password length is 8 characters.", seconds: 2.0, icon: "👮")
        }
        
        guard state!.recoveryMode() || confirmation != nil else {
            viewEncryptionPassword.resignFirstResponder()
            return performSegue(withIdentifier: "SetupEncryptionConfirmationSegue", sender: sender)
        }
        
        guard state!.recoveryMode() || viewEncryptionPassword.text == confirmation else {
            confirmation = nil
            viewEncryptionPassword.becomeFirstResponder()
            return BannerHelper.error("The password and confirmation do not match", seconds: 2.0, icon: "👮")
        }
        
        guard !state!.recoveryMode() || verifyRecoveryChallenge() else {
            viewEncryptionPassword.becomeFirstResponder()
            return BannerHelper.error("The password you entered is incorrect", seconds: 2.0, icon: "👮")
        }
        
        performSegue(withIdentifier: "SetupPINCodeSegue", sender: sender)
    }
    
    /// Verify if the current password is correct (if the user is recovering data)
    ///
    /// - Returns: Positive if the password was correct or if the user is not recovering data.
    private func verifyRecoveryChallenge() -> Bool {
        if let challenge = state?.challenge?.challenge {
            do {
                let _ = try CryptographyHelper.shared.decrypt(challenge, withKey: viewEncryptionPassword.text ?? "")
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
    
    /// Prepare for the setup encryption segue
    ///
    /// - Parameter segue: The segue object containing information about the view controllers involved in the segue.
    /// - Parameter sender: The object that initiated the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "SetupEncryptionConfirmationSegue" {
            if let destination = segue.destination as? SetupEncryptionConfirmationViewController {
                destination.sendingController = self
            }
        }
        
        if segue.identifier == "SetupPINCodeSegue" {
            if let destination = segue.destination as? SetupPINCodeViewController {
                state!.password = viewEncryptionPassword.text
                destination.state = state
            }
        }
    }
    
}
