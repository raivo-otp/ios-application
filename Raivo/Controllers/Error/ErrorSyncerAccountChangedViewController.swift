//
//  ErrorSyncerAccountChangedViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 19/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import SVGKit

class ErrorSyncerAccountChangedViewController: UIViewController {
    
    @IBOutlet weak var viewIcon: SVGKFastImageView!
    
    @IBOutlet weak var viewTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "error-syncer-account-changed", withExtension: "svg", subdirectory: "Vectors")
        
        viewTitle.text = "Your " + SyncerHelper.shared.getSyncer().name + " account changed"
        viewIcon.image = SVGKImage(contentsOf: url)
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
