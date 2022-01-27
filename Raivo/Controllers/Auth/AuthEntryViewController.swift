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

import UIKit
import Haptica

/// The controller for the main view in the authentication flow
class AuthEntryViewController: UIViewController, UIPasscodeFieldDelegate {

    /// A field representing the six passcode digits
    @IBOutlet weak var passcodeField: UIPasscodeField!
    
    /// A button to force a biometric unlock
    @IBOutlet weak var biometricButton: UIButton!
    
    /// If Raivo is currently attempting a biometric unlock
    private var attemptingBiometricUnlock: Bool = false
    
    /// Called after the view controller has loaded its view hierarchy into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        biometricButton.isHidden = !StorageHelper.shared.getBiometricUnlockEnabled()
        
        passcodeField.delegate = self
        passcodeField.layoutIfNeeded()
        
        NotificationHelper.shared.listen(to: UIApplication.willEnterForegroundNotification, distinctBy: id(self)) { _ in
            self.attemptBiometrickUnlock()
        }
    }
    
    /// Called before the view controller's view is about to be added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition should be animated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        attachKeyboardConstraint(self)
    }
    
    /// Called in response to a view being removed from a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition should be animated
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        detachKeyboardConstraint(self)
    }
    
    /// Notifies the view controller that its view was removed from a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationHelper.shared.discard(UIApplication.willEnterForegroundNotification, byDistinctName: id(self))
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        attemptBiometrickUnlock()
    }
    
    /// Called when the user taps on the "biometric unlock" button/link
    ///
    /// - Parameter sender :The button that was tapped
    @IBAction func onBiometricsUnlock(_ sender: Any) {
        attemptBiometrickUnlock()
    }
    
    /// Called when the user enters or removes a single digit
    ///
    /// - Parameter passcode: The new passcode value
    func onPasscodeChange(passcode: String) {
        // Not implemented, we don't listen to digit changes
    }
    
    /// Called when the user completes entering his/her passcode
    ///
    /// - Parameter passcode: The complete passcode value
    /// - Note This function will unlock the application if the passcode is correct
    func onPasscodeComplete(passcode: String) {
        // Always calculate the result to prevent time-bases guessing attacks
        let (correct, encryptionKey) = isCorrectPasscode(passcode)
        
        // Prevent unlock if user tried to unlock too many times
        if !hasPasscodeAttemptLeft() {
            passcodeField.reset()
            
            let message = "Wait " + String(getSecondsLeft()) + " seconds to try again"
            return BannerHelper.shared.error("No attempts left", message, wrapper: self.view)
        }
        
        increasePasscodeTries()
        
        // Make sure the passcode is correct
        guard correct else {
            passcodeField.reset()
            
            log.verbose("Invalid passcode entered")
            
            var message = "Wait \(String(Int(AppHelper.Authentication.passcodeLockoutSeconds))) seconds to try again"
            let triesLeft = getTriesLeft()
            
            if triesLeft > 1 {
                message = "Only \(triesLeft) tries left"
            } else if triesLeft == 1 {
                message = "Only \(triesLeft) try left"
            }
            
            return BannerHelper.shared.error("Invalid passcode", message, wrapper: self.view)
        }
        
        log.verbose("Valid passcode entered")
        resetPasscodeTries()
        
        getAppDelegate().updateEncryptionKey(encryptionKey!)
        getAppDelegate().updateStoryboard()
    }
    
    /// Verify if the given passcode can unlock the current Realm database
    ///
    /// - Parameter passcode: The passcode to check
    /// - Returns: A tupple containing if the passcode is correct, and the encryption key that was tried
    internal func isCorrectPasscode(_ passcode: String) -> (Bool, Data?) {
        let salt = StorageHelper.shared.getEncryptionPassword()!

        guard let encryptionKey = try? CryptographyHelper.shared.derive(passcode, withSalt: salt) else {
            return (false, nil)
        }

        return (RealmHelper.shared.isCorrectEncryptionKey(encryptionKey), encryptionKey)
    }
    
    /// Increase the amount of times the user tried to unlock the application
    internal func increasePasscodeTries() {
        let currentTries = StorageHelper.shared.getPasscodeTriedAmount() ?? 0
        
        // Force 'passcode tried' set. We rather crash than letting someone try again
        try! StorageHelper.shared.setPasscodeTriedAmount(currentTries + 1)
        try! StorageHelper.shared.setPasscodeTriedTimestamp(Date().timeIntervalSince1970)
    }
    
    /// Check if the user may try to unlock the device based on the amount of tries left
    ///
    /// - Returns: Positive if there is a try left, false otherwise
    internal func hasPasscodeAttemptLeft() -> Bool {
        let lastTryTimestamp = StorageHelper.shared.getPasscodeTriedTimestamp() ?? TimeInterval(0)
        let lockoutSeconds = AppHelper.Authentication.passcodeLockoutSeconds
        
        if getTriesLeft() > 0 {
            return true
        }
        
        return (lastTryTimestamp + lockoutSeconds) < Date().timeIntervalSince1970
    }
    
    /// If a user unlocked the application, this function may be used to reset the unlock tries and timestamp
    internal func resetPasscodeTries() {
        // We try to reset the 'passcode tries', but if it fails it doesn't really matter
        try? StorageHelper.shared.setPasscodeTriedAmount(0)
        try? StorageHelper.shared.setPasscodeTriedTimestamp(0)
    }
    
    /// Get the amount of tries that a user has left to unlock the application
    ///
    /// - Returns: The amount of tries the user has left
    internal func getTriesLeft() -> Int {
        let maximum = AppHelper.Authentication.passcodeMaximumTries
        return maximum - (StorageHelper.shared.getPasscodeTriedAmount() ?? 0)
    }
    
    /// Get the amount of seconds a user has to wait before he/she can unlock the application again
    ///
    /// - Returns: The amount of seconds left
    internal func getSecondsLeft() -> Int {
        let lastTryTimestamp = StorageHelper.shared.getPasscodeTriedTimestamp() ?? TimeInterval(0)
        let lockoutSeconds = AppHelper.Authentication.passcodeLockoutSeconds
        
        return Int(lastTryTimestamp + lockoutSeconds - Date().timeIntervalSince1970)
    }
    
    /// Attempt to unlock the application via biometric (e.g. FaceID or TouchID)
    internal func attemptBiometrickUnlock() {
        // Biometric unlock must be enabled
        guard StorageHelper.shared.getBiometricUnlockEnabled() else {
            passcodeField.becomeFirstResponder()
            return
        }
        
        // Already attempting biometric unlock
        guard !attemptingBiometricUnlock else {
            return
        }
        
        // User must have a passcode attempt left
        guard hasPasscodeAttemptLeft() else {
            let message = "Wait " + String(getSecondsLeft()) + " seconds and try again"
            return BannerHelper.shared.error("Invalid passcode", message, wrapper: self.view)
        }
        
        passcodeField.resignFirstResponder()
        attemptingBiometricUnlock = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let key = StorageHelper.shared.getEncryptionKey(prompt: "Unlock Raivo in no time") {
                self.attemptingBiometricUnlock = false
                self.resetPasscodeTries()

                log.verbose("Unlocked app via biometric")

                getAppDelegate().updateEncryptionKey(Data(base64Encoded: key))
                getAppDelegate().updateStoryboard()
            } else {
                self.attemptingBiometricUnlock = false
                self.passcodeField.becomeFirstResponder()
            }
        }
    }

}
