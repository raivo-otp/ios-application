//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit

class ErrorSyncerAccountChangedViewController: ErrorRootViewController {
    
    @IBOutlet weak var viewTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTitle.text = "Your " + SyncerHelper.shared.getSyncer().name + " account is unavailable"
    }
    
    @IBAction func onContinue(_ sender: Any) {
        let refreshAlert = UIAlertController(
            title: "Are you sure?",
            message: "Your local Raivo data will be deleted.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
            StateHelper.shared.reset()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
}
