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
import Eureka
import CloudKit
import RealmSwift
import MessageUI

class AuthMiscViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    private var miscellaneousForm: MiscellaneousForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form).build(controller: self).ready()
        tableView.alwaysBounceVertical = false
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
