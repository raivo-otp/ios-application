//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import UIKit
import Eureka
import MessageUI

/// On setup, a user can click on the "settings" icon. This controller will be launched if "settings" is clicked.
class SetupMiscViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    /// A reference to the form to load into this form view
    private var miscellaneousForm: MiscellaneousForm?
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form).build(controller: self).ready()
        
        tableView.backgroundColor = UIColor.getBackgroundEureka()
        tableView.alwaysBounceVertical = false
    }
    
    /// Delegate callback which is called upon user's completion of email composition.
    ///
    /// - Parameter controller: The MFMailComposeViewController instance which is returning the result.
    /// - Parameter result: MFMailComposeResult indicating how the user chose to complete the composition process.
    /// - Parameter error: NSError indicating the failure reason if failure did occur.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
