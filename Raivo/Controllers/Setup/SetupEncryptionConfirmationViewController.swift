//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
//

import UIKit

/// Enable the user to confirm the master password (confirm, not initial)
class SetupEncryptionConfirmationViewController: UIViewController, UITextFieldDelegate {

    /// A reference to the password confirmation field
    @IBOutlet weak var password: UITextField!
    
    /// The sender (previous) controller (because this view is presented as a popover)
    public var sendingController: SetupEncryptionInitialViewController? = nil

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint(self)
        password.becomeFirstResponder()
    }

    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
    }
    
    /// On 'return' on the keyboard, perform the same action as the "continue" button.
    ///
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: Positive if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendingController!.confirmation = password.text ?? ""
        
        dismiss(animated: true) {
            self.sendingController?.onContinue(self)
        }
        
        return false
    }
   
    /// Triggers when the confirm button is tapped
    ///
    /// - Parameter sender: The object that triggered the action.
    @IBAction func onContinue(_ sender: Any) {
        sendingController!.confirmation = password.text ?? ""
        
        dismiss(animated: true) {
            self.sendingController?.onContinue(self)
        }
    }
    
}
