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

    /// The sender (previous) controller (because this view is presented as a popover)
    public var sendingController: SetupPINCodeViewController? = nil

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustViewToKeyboard()
        
        pincodeField.delegate = self
        pincodeField.layoutIfNeeded()
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pincodeField.becomeFirstResponder()
    }
    
    /// Called if the user finished entering the PIN code.
    ///
    /// - Parameter pincode: The  PIN code that the user entered.
    func onPincodeComplete(pincode: String) {
        sendingController!.confirmation = pincode
        
        dismiss(animated: true) {
            self.sendingController?.onContinue()
        }
    }
    
    /// If the PIN code changes, set the confirmation to nil.
    ///
    /// - Parameter pincode: The new (possibly incomplete) PIN code.
    func onPincodeChange(pincode: String) {
        // Not implemented
    }
    
}
