//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit
import Haptica
import RealmSwift

/// This controller allows users to change their passcode.
///
/// - Todo: Remove old Spring code.
class MainChangePasscodeViewController: UIViewController, UIPasscodeFieldDelegate {

    /// The title centered in the view
    @IBOutlet weak var viewTitle: UILabel!
    
    /// Extra information that supports the title
    @IBOutlet weak var viewExtra: UILabel!
    
    /// The actual passcode field
    @IBOutlet weak var viewPasscode: UIPasscodeField!
    
    /// Derived passcode+salt from the first try (a user needs to enter the same passcode twice before it will change)
    private var initialKey: Data? = nil
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetView(
            "Choose a new passcode",
            "And make sure you'll be able to remember it."
        )
        
        viewPasscode.delegate = self
        viewPasscode.layoutIfNeeded()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    /// The background color is a fix for the grey shadow under the navigation bar.
    /// https://stackoverflow.com/a/25421617/2491049
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint(self)
        
        navigationController?.view.backgroundColor = UIColor.white
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewPasscode.becomeFirstResponder()
    }
    
    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
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
    
    /// Triggered when the user entered a passcode.
    /// This method will either;
    ///     * Move on to the second passcode try
    ///     * Notify if the second passcode try was wrong
    ///     * Migrate the database using the new passcode
    ///
    /// - Parameter passcode: The x digit passcode
    internal func onPasscodeComplete(passcode: String) {
        var currentKey: Data? = nil
        let salt = StorageHelper.shared.getEncryptionPassword()
        
        do {
            currentKey = try CryptographyHelper.shared.derive(passcode, withSalt: salt!)
        } catch let error {
            ui { self.resetView("Invalid passcode", "Please start over by choosing a new passcode.", haptica: .error) }
            return log.error(error.localizedDescription)
        }
        
        switch initialKey {
        case nil:
            initialKey = currentKey
            
            ui {
                self.resetView("Confirm your passcode", "You'll be signed out after this step")
            }
        case currentKey:
            changePasscode(to: currentKey!)
        default:
            initialKey = nil
            
            ui {
                BannerHelper.shared.error("Not identical", "The passcode and confirmation do not match", wrapper: self.view)
                
                self.resetView(
                    "Choose a new passcode",
                    "And make sure you'll be able to remember it."
                )
            }
        }
    }
    
    /// Triggered when the user changed the passcode input
    ///
    /// - Parameter passcode: The (possibly incomplete) digit passcode
    func onPasscodeChange(passcode: String) {
        // Not implemented
    }
    
    /// Reset the controller's view using the given text and other parameters
    ///
    /// - Parameter title: The title centered in the view
    /// - Parameter extra: Extra information that supports the title
    /// - Parameter haptica: Optionally vibrate for user feedback
    private func resetView(_ title: String, _ extra: String, haptica: HapticFeedbackType? = nil) {
        viewTitle.text = title
        viewExtra.text = extra
        
        viewPasscode.reset()
        
        if let type = haptica {
            Haptic.notification(type).generate()
        }
    }
    
    /// Migrate the old Realm database to the a new Realm database using the new encryption key
    ///
    /// - Parameter newKey: The new encryption key
    private func changePasscode(to newKey: Data) {
        let newName = RealmHelper.shared.getProposedNewFileName()
        let newFile = RealmHelper.shared.getFileURL(forceFilename: newName)
        
        let result = autoreleasepool { () -> Bool in
            let oldRealm = RealmHelper.shared.getRealm()
            
            do {
                try oldRealm!.writeCopy(toFile: newFile!, encryptionKey: newKey)
                return true
            } catch let error {
                log.error(error.localizedDescription)
                return false
            }
        }
        
        guard result else {
            return
        }
        
        do {
            if StorageHelper.shared.getBiometricUnlockEnabled() {
                try StorageHelper.shared.setEncryptionKey(newKey.base64EncodedString())
            }
        } catch {
            log.error("Could not set encryption key while changing passcode: \(error)")
            BannerHelper.shared.error("Error", "Could not save passcode")
            return
        }
        
        do {
            try StorageHelper.shared.setRealmFilename(newName)
        } catch {
            log.error("Could not set realm filename whilechanging passcode: \(error)")
            BannerHelper.shared.error("Error", "Could not save passcode")
            return
        }
    
        StateHelper.shared.reset(dueToPasscodeChange: true)
        getAppDelegate().updateStoryboard()
    }
    
}
