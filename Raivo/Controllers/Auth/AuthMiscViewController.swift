//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit
import Eureka
import MessageUI

/// The controller for the miscellaneous view in the authentication flow
class AuthMiscViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    /// The miscellaneous form
    private var miscellaneousForm: MiscellaneousForm?
    
    /// Called after the view controller has loaded its view hierarchy into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form)
        miscellaneousForm?.build(controller: self)
        miscellaneousForm?.ready()
        
        // Fix the double scroll view in SPStorkController scroll view
        tableView.alwaysBounceVertical = false
    }
    
    /// Called after the ZIP-archive (password export) is mailed to the user
    ///
    /// - Parameter controller: The "send mail" controller
    /// - Parameter result: The result of the "send mail" controller
    /// - Parameter error: An error, if one occurred
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
