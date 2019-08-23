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

/// Enable the user to confirm the master password (confirm, not initial)
class SetupPINCodeConfirmationViewController: UIViewController, UIPincodeFieldDelegate {
    
    /// A reference to the PIN code field
    @IBOutlet weak var pincodeField: UIPincodeField!
    
    /// If the user finished entering the confirmation PIN code
    private var completed: Bool = false

    /// The sender (previous) controller (because this view is presented as a popover)
    public var sendingController: SetupPINCodeViewController? = nil

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
                
        pincodeField.delegate = self
        pincodeField.layoutIfNeeded()
        pincodeField.becomeFirstResponder()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint()
    }

    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint()
        
        if !completed {
            self.sendingController?.pincodeField.reset()
        }
    }
    
    /// Notifies the view controller that its view was removed from a view hierarchy.
    ///
    /// - Parameter animated: If true, the disappearance of the view was animated.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pincodeField.reset()
    }
    
    /// Called if the user finished entering the PIN code.
    ///
    /// - Parameter pincode: The  PIN code that the user entered.
    func onPincodeComplete(pincode: String) {
        completed = true
        
        // Allow UIPincodeField to finish animations before continueing
        DispatchQueue.main.async {
            self.sendingController!.confirmation = pincode
            
            self.dismiss(animated: true) {
                self.sendingController?.onContinue()
            }
        }
    }
    
    /// If the PIN code changes, set the confirmation to nil.
    ///
    /// - Parameter pincode: The new (possibly incomplete) PIN code.
    func onPincodeChange(pincode: String) {
        // Not implemented
    }
    
}
