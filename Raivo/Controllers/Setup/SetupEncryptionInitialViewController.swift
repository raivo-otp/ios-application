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

/// Enable the user to set the master password (initial, not confirm)
class SetupEncryptionInitialViewController: UIViewController, UITextFieldDelegate, SetupState {

    /// If the user confirmed the password, this var will contain the confirmed password
    public var confirmation: String? = nil
    
    /// A reference to the title label of the view
    @IBOutlet weak var viewTitle: UILabel!
    
    /// A reference to the description label of the view
    @IBOutlet weak var viewDescription: UILabel!
    
    /// A reference to the password field
    @IBOutlet weak var password: UITextField!

    //// A reference the the "I forgot my password" button
    @IBOutlet weak var forgotView: UIButton!
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if state(self).recoveryMode() {
            viewTitle.text = "Load data from storage provider."
            viewDescription.text = "You've used Raivo before. Enter the recovery password you took note of back then."
            forgotView.isHidden = false
        }
    
        password.delegate = self
        password.becomeFirstResponder()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint(self)
    }

    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if confirmation == nil {
            password.becomeFirstResponder()
        }
    }
    
    /// On 'return' on the keyboard, perform the same action as the "continue" button.
    ///
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: Positive if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onContinue(textField)
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
        guard password.text?.count ?? 0 >= 8 else {
            password.becomeFirstResponder()
            return BannerHelper.shared.error("Invalid password", "The minimum length is 8 characters", wrapper: view)
        }
        
        guard state(self).recoveryMode() || !CryptographyHelper.shared.passwordIsVeryWeak(password.text ?? "") else {
            password.becomeFirstResponder()
            return BannerHelper.shared.error("Weak password", "Please try another one", wrapper: view)
        }
        
        guard state(self).recoveryMode() || confirmation != nil else {
            return performSegue(withIdentifier: "SetupPasswordConfirmationSegue", sender: sender)
        }
        
        guard state(self).recoveryMode() || password.text == confirmation else {
            confirmation = nil
            password.becomeFirstResponder()
            return BannerHelper.shared.error("Not identical", "The password and confirmation do not match", wrapper: view)
        }
        
        guard !state(self).recoveryMode() || verifyRecoveryChallenge() else {
            password.becomeFirstResponder()
            return BannerHelper.shared.error("Incorrect password", "The password you entered is incorrect", wrapper: view)
        }

        state(self).password = password.text
        performSegue(withIdentifier: "SetupPasscodeSegue", sender: sender)
    }
    
    /// Verify if the current password is correct (if the user is recovering data)
    ///
    /// - Returns: Positive if the password was correct or if the user is not recovering data.
    private func verifyRecoveryChallenge() -> Bool {
        if let challenge = state(self).challenge?.challenge {
            do {
                let _ = try CryptographyHelper.shared.decrypt(challenge, withKey: password.text ?? "")
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
        
        if segue.identifier == "SetupPasswordConfirmationSegue" {
            if let destination = segue.destination as? SetupEncryptionConfirmationViewController {
                destination.sendingController = self
            }
        }
    }
    
}
