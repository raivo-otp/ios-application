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
import RealmSwift
import Spring

/// This controller allows users to change their PIN code
class MainChangePincodeViewController: UIViewController, UIPincodeFieldDelegate {

    /// The title centered in the view
    @IBOutlet weak var viewTitle: UILabel!
    
    /// Extra information that supports the title
    @IBOutlet weak var viewExtra: SpringLabel!
    
    /// The actual PIN code field
    @IBOutlet weak var viewPincode: UIPincodeField!
    
    /// Derived PIN+salt from the first try (a user needs to enter the same PIN twice before it will change)
    private var initialKey: Data? = nil
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustViewToKeyboard()
         
        resetView(
            "Choose a new PIN code",
            "You need it to unlock Raivo, so make sure you'll be able to remember it."
        )
        
        viewPincode.delegate = self
        viewPincode.becomeFirstResponder()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    /// The background color is a fix for the grey shadow under the navigation bar.
    /// https://stackoverflow.com/a/25421617/2491049
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.backgroundColor = UIColor.white
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewPincode.becomeFirstResponder()
    }

    /// Notifies the view controller that its view was removed from a view hierarchy.
    /// The background color is a fix for the grey shadow under the navigation bar.
    /// https://stackoverflow.com/a/25421617/2491049
    ///
    /// - Parameter animated: If positive, the disappearance of the view was animated.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
    /// Triggered when the user entered a PIN code.k
    /// This method will either;
    ///     * Move on to the second PIN code try
    ///     * Notify if the second PIN code try was wrong
    ///     * Migrate the database using the new PIN code
    ///
    /// - Parameter pincode: The x digit PIN code
    internal func onPincodeComplete(pincode: String) {
        var currentKey: Data? = nil
        let salt = StorageHelper.shared.getEncryptionPassword()
        
        do {
            currentKey = try CryptographyHelper.shared.derive(pincode, withSalt: salt!)
        } catch let error {
            ui { self.resetView("Invalid PIN code", "Please start over by choosing a new PIN code.") }
            return log.error(error)
        }
        
        switch initialKey {
        case nil:
            initialKey = currentKey
            
            ui {
                self.resetView(
                    "Almost there!",
                    "Confirm your PIN code to continue (you'll be signed out after this step)."
                )
            }
        case currentKey:
            changePincode(to: currentKey!)
        default:
            initialKey = nil
            
            ui {
                self.resetView(
                    "Oh oh, not similar :/",
                    "Please start over by choosing a new PIN code.",
                    flash: true
                )
            }
        }
    }
    
    /// Reset the controller's view using the given text and other parameters
    ///
    /// - Parameter title: The title centered in the view
    /// - Parameter extra: Extra information that supports the title
    /// - Parameter flash: If the extra message should flash/wobble
    private func resetView(_ title: String, _ extra: String, flash: Bool = false) {
        viewTitle.text = title
        viewExtra.text = extra
        
        viewPincode.reset()
      
        if flash {
            viewExtra.delay = CGFloat(0.25)
            viewExtra.animation = "shake"
            viewExtra.animate()
        }
    }
    
    /// Migrate the old Realm database to the a new Realm database using the new encryption key
    ///
    /// - Parameter newKey: The new encryption key
    private func changePincode(to newKey: Data) {
        let newName = RealmHelper.getProposedNewFileName()
        let newFile = RealmHelper.getFileURL(forceFilename: newName)
        
        let oldRealm = try! Realm()
        
        do {
            try oldRealm.writeCopy(toFile: newFile!, encryptionKey: newKey)
        } catch let error {
            return log.error(error)
        }
        
        if StorageHelper.shared.getBiometricUnlockEnabled() {
            StorageHelper.shared.setEncryptionKey(newKey.base64EncodedString())
        }
        
        StorageHelper.shared.setRealmFilename(newName)
        StateHelper.shared.reset(dueToPINCodeChange: true)
        
        getAppDelegate().updateStoryboard()
    }
    
}
