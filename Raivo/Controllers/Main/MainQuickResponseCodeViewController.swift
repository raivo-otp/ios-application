//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import Foundation
import Eureka

/// This controller allows users to export a password using a QRCode
class MainQuickResponseCodeViewController: FormViewController {
    
    /// The form to show in the view
    private var quickResponseCodeForm: QuickResponseCodeForm?
    
    /// The current password to show the QR code for
    public var password: Password?

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quickResponseCodeForm = QuickResponseCodeForm(form).build(password!)
    }

}
