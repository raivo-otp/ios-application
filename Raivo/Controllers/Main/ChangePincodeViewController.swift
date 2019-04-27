//
//  ChangePincodeViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Spring

class ChangePincodeViewController: UIViewController, PincodeDigitsProtocol {
    
    @IBOutlet weak var pincodeDigitsView: PincodeDigitsView!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    private var initialPincode: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        self.pincodeDigitsView.delegate = self
        self.showPincodeView("Choose a new PIN code", "You need it to unlock Raivo, so make sure you'll be able to remember it.", focus: false)
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pincodeDigitsView.focus()
    }
    
    func showPincodeView(_ title: String, _ extra: String, focus: Bool = true, flash: Bool = false) {
        self.viewTitle.text = title
        self.viewExtra.text = extra
        
        if focus {
            self.pincodeDigitsView.resetAndFocus()
        } else {
            self.pincodeDigitsView.reset()
        }
        
        if flash {
            self.viewExtra.delay = CGFloat(0.25)
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
        }
    }
    
    func onPincodeComplete(pincode: String) {
        
        DispatchQueue.main.async {
            let salt = KeychainHelper.settings().string(forKey: KeychainHelper.KEY_PASSWORD)!
            
            if self.initialPincode == nil {
                self.pincodeDigitsView.resetAndFocus()
                self.initialPincode = KeyDerivationHelper.derivePincode(pincode, salt)
                self.showPincodeView("Almost there!", "Confirm your PIN code to continue (you'll be signed out after this step).")
            } else {
                if self.initialPincode == KeyDerivationHelper.derivePincode(pincode, salt) {
                    self.changePincode(pincode, salt)
                } else {
                    self.initialPincode = nil
                    self.pincodeDigitsView.resetAndFocus()
                    self.showPincodeView("Oh oh, not similar :/", "Please start over by choosing a new PIN code.", flash: true)
                }
            }
        }
    }
    
    private func changePincode(_ pincode: String, _ salt: String) {
        let newKey = KeyDerivationHelper.derivePincode(pincode, salt)
        let newName = RealmHelper.getProposedNewFileName()
        let newFile = RealmHelper.getFileURL(forceFilename: newName)
        
        let oldRealm = try! Realm()
        
        do {
            try oldRealm.writeCopy(toFile: newFile!, encryptionKey: newKey)
        } catch let error {
            log.error(error)
            return
        }
        
        KeychainHelper.settings().set(string: newName, forKey: KeychainHelper.KEY_REALM_FILENAME)
        
        StateHelper.reset(clearKeychain: false)
        updateStoryboard()
    }
    
}
