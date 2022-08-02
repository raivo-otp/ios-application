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
