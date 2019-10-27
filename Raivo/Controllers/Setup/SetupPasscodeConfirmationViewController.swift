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

/// Enable the user to confirm the master password (confirm, not initial)
class SetupPasscodeConfirmationViewController: UIViewController, UIPasscodeFieldDelegate {
    
    /// A reference to the passcode field
    @IBOutlet weak var passcodeField: UIPasscodeField!
    
    /// If the user finished entering the confirmation passcode
    private var completed: Bool = false

    /// The sender (previous) controller (because this view is presented as a popover)
    public var sendingController: SetupPasscodeViewController? = nil

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
        passcodeField.becomeFirstResponder()
    }

    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
        
        if !completed {
            self.sendingController?.passcodeField.reset()
        }
    }
    
    /// Notifies the view controller that its view was removed from a view hierarchy.
    ///
    /// - Parameter animated: If true, the disappearance of the view was animated.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        passcodeField.reset()
    }
    
    /// Called if the user finished entering the passcode.
    ///
    /// - Parameter passcode: The passcode that the user entered.
    func onPasscodeComplete(passcode: String) {
        completed = true
        
        // Allow UIPasscodeField to finish animations before continueing
        DispatchQueue.main.async {
            self.sendingController!.confirmation = passcode
            
            self.dismiss(animated: true) {
                self.sendingController?.onContinue()
            }
        }
    }
    
    /// If the passcode changes, set the confirmation to nil.
    ///
    /// - Parameter passcode: The new (possibly incomplete) passcode.
    func onPasscodeChange(passcode: String) {
        // Not implemented
    }
    
}
