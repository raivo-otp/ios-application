//
//  EnableBiometricsViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 01/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Spring
import SVGKit

class EnableBiometricsViewController: UIViewController {
    
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
        updateStoryboard()
    }
    
    @IBAction func onEnableTouchID(_ sender: Any) {
        let key = getAppDelagate().getEncryptionKey()!.base64EncodedString()
        StorageHelper.secrets().set(string: key, forKey: StorageHelper.KEY_ENCRYPTION_KEY)
        
        let prompt = "Confirm to enable TouchID"
        let result = StorageHelper.secrets().string(forKey: StorageHelper.KEY_ENCRYPTION_KEY, withPrompt: prompt)
        
        switch result {
        case .success(_):
            StorageHelper.settings().set(string: String(true), forKey: StorageHelper.KEY_TOUCHID_ENABLED)
            updateStoryboard()
        default:
            return
        }
        
    }
}
