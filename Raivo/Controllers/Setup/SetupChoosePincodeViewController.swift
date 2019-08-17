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
import Valet

/// This controller allows users to setup their PIN code
class SetupChoosePincodeViewController: UIViewController, UIPincodeFieldDelegate {
    
    /// The title centered in the view
    @IBOutlet weak var viewTitle: UILabel!
    
    /// Extra information that supports the title
    @IBOutlet weak var viewExtra: SpringLabel!
    
    /// The actual PIN code field
    @IBOutlet weak var viewPincodeInitial: UIPincodeField!
    
    /// The PIN code confirmation field
    @IBOutlet weak var viewPincodeConfirm: UIPincodeField!
    
    /// Derived PIN+salt from the first try (a user needs to enter the same PIN twice before it will change)
    private var initialKey: Data? = nil
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustViewToKeyboard()
        
        resetView(
            "Choose your PIN code",
            "You need it to unlock Raivo, so make sure you'll be able to remember it.",
            fields: [viewPincodeInitial, viewPincodeConfirm]
        )
        
        viewPincodeInitial.delegate = self
        viewPincodeConfirm.delegate = self
        viewPincodeInitial.layoutIfNeeded()
        viewPincodeConfirm.layoutIfNeeded()
        
        viewPincodeConfirm.isHidden = true
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewPincodeInitial.becomeFirstResponder()
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
            ui {
                self.resetView(
                    "Invalid PIN code",
                    "Please start over by choosing a new PIN code.",
                    animation: "shake",
                    fields: [self.viewPincodeInitial, self.viewPincodeConfirm]
                )
                
                self.viewPincodeInitial.becomeFirstResponder()
            }
            
            return log.error(error)
        }
        
        switch initialKey {
        case nil:
            initialKey = currentKey
            
            ui {
                self.resetView(
                    "Almost there!",
                    "Confirm your PIN code to continue.",
                    animation: "morph" // squeeze, swing, morph
                )
                
                self.viewPincodeConfirm.isHidden = false
                self.viewPincodeConfirm.becomeFirstResponder()
            }
        case currentKey:
            createDatabase(using: currentKey!)
        default:
            initialKey = nil
            
            ui {
                self.resetView(
                    "Oh oh, not similar :/",
                    "Start over and choose a new PIN code.",
                    animation: "shake",
                    fields: [self.viewPincodeInitial, self.viewPincodeConfirm]
                )
                
                self.viewPincodeConfirm.isHidden = true
                self.viewPincodeInitial.becomeFirstResponder()
            }
        }
    }
    
    /// Reset the controller's view using the given text and other parameters
    ///
    /// - Parameter title: The title centered in the view
    /// - Parameter extra: Extra information that supports the title
    /// - Parameter animation: The spring animation that should trigger
    /// - Parameter fields: Which UIPincodeField's should be reset to their initial state?
    private func resetView(_ title: String, _ extra: String, animation: String? = nil, fields: [UIPincodeField] = []) {
        viewTitle.text = title
        viewExtra.text = extra
        
        for field in fields {
            field.reset()
            field.layoutIfNeeded()
        }
        
        if let animation = animation {
            viewExtra.delay = CGFloat(0.25)
            viewExtra.duration = CGFloat(1.0)
            viewExtra.animation = animation
            viewExtra.animate()
        }
    }
    
    /// Create a Realm database using the given encryption key
    ///
    /// - Parameter encryptionKey: The new encryption key
    private func createDatabase(using encryptionKey: Data) {
        getAppDelegate().updateEncryptionKey(encryptionKey)
        
        let _ = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        
        if StorageHelper.shared.canAccessSecrets() {
            performSegue(withIdentifier: "EnableBiometricsSegue", sender: nil)
        } else {
            getAppDelegate().updateStoryboard()
        }
    }
    
}
