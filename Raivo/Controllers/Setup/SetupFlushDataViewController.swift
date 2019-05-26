//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import UIKit

class SetupFlushDataViewController: UIViewController {
    
    @IBAction func confirm(_ sender: Any) {
        let popup = UIAlertController(title: "Are you sure?", message: "ALL your data will be deleted and you will NOT be able to recover it!", preferredStyle: .alert)
        
        popup.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
            self.flushData()
        }))
        
        popup.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            popup.dismiss(animated: true, completion: nil)
        }))
        
        present(popup, animated: true, completion: nil)
    }
    
    private func flushData() {
        let _ = displayNavBarActivity()
        
        SyncerHelper.shared.getSyncer().flushAllData(success: { (syncerType) in
            self.dismissNavBarActivity()
            StateHelper.shared.reset()           
        }) { (error, syncerType) in
            self.dismissNavBarActivity()
            
            let popup = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            
            popup.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                popup.dismiss(animated: true, completion: nil)
            }))
            
            self.present(popup, animated: true, completion: nil)
        }
    }
    
}
