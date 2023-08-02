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

import Foundation
import UIKit

/// A shadow/mirror UITextField that doesn't allow any actions other that adding and removing characters
class UIPasscodeShadowField: UITextField {
    
    /// Initialize the current UITextField using a frame
    ///
    /// - Parameter frame: The frame to use
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Initialzie the current UITextField using a coder
    ///
    /// - Parameter aDecoder: The coder to use
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// A function that is ran by all public initializers
    private func commonInit() {
        keyboardType = .numberPad
        keyboardAppearance = .dark
        autocorrectionType = .no
        autocapitalizationType = .none
        isSecureTextEntry = true
    }
    
    /// Requests the receiving responder to enable or disable the specified command in the user interface.
    ///
    /// - Parameter action: The action that has to be approved
    /// - Parameter sender: The sender that initiated the action
    /// - Returns: Always negative, users can't perform any actions on this field
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
}
