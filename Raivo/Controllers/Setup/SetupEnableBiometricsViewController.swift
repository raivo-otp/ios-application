//
//  SetupEnableBiometricsViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 01/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Spring
import SVGKit

class SetupEnableBiometricsViewController: UIViewController {
    
    //EnableBiometricsSegue
    @IBOutlet weak var viewIcon: SVGKFastImageView!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        let url = Bundle.main.url(forResource: "fingerprint", withExtension: "svg", subdirectory: "Vectors")
        viewIcon.image = SVGKImage(contentsOf: url)
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    
    @IBAction func onDismissTouchID(_ sender: Any) {
        getAppDelagate().updateStoryboard()
    }
    
    @IBAction func onEnableTouchID(_ sender: Any) {
        StorageHelper.setEncryptionKey(getAppDelagate().getEncryptionKey()!.base64EncodedString())
        
        if let _ = StorageHelper.getEncryptionKey(prompt: "Confirm to enable TouchID") {
            StorageHelper.setBiometricUnlockEnabled(true)
            getAppDelagate().updateStoryboard()
        }
    }
}
