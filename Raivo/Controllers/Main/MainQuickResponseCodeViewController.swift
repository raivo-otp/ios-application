//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import Eureka
import UIKit

/// This controller allows users to export a password using a QRCode
class MainQuickResponseCodeViewController: FormViewController {
    
    /// The form to show in the view
    private var quickResponseCodeForm: QuickResponseCodeForm?
    
    /// The initial brightness of the screen upon arrival
    private var previousBrightness: CGFloat?
    
    /// The current password to show the QR code for
    public var password: Password?

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quickResponseCodeForm = QuickResponseCodeForm(form).build(password!)
        previousBrightness = UIScreen.main.brightness
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIScreen.animateBrightness(to: 1.0)
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.animateBrightness(to: previousBrightness!)
    }

}
