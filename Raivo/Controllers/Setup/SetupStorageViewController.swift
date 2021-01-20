//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import UIKit
import Eureka

/// This controllers enables the user to select a certain synchronization providr
class SetupStorageViewController: FormViewController, SetupState {
    
    /// A reference to the form to load into this form view
    private var synchronizationProviderForm: SynchronizationProviderForm?
    
    /// The available syncrhonization accounts
    public var accounts: [String: SyncerAccount] = [:]
    
    /// The available challenges belonging to the syncrhonization accounts
    public var challenges: [String: SyncerChallenge] = [:]
    
    /// Keep track of the progress of all the synchronization providers. All providers will be true when loaded
    private var progress: [String: Bool] = [:]
    
    /// Keep track of the original bar button so it can be restored after the navigation bar activity has been shown
    private var originalBarButton: UIBarButtonItem?
    
    /// A reference to the "Continue" button
    @IBOutlet weak var continueButton: UIButton!
    
    /// A reference to the title label of the view
    @IBOutlet weak var viewTitle: UILabel!
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        synchronizationProviderForm = SynchronizationProviderForm(form).build()
        continueButton.setTitle("Loading...", for: UIControl.State.disabled)
        
        resolveSyncers()
    }
    
    /// Start loading all the available synchronization providers and challenges
    private func resolveSyncers() {
        originalBarButton = displayNavBarActivity()
        
        for availableSyncer in SyncerHelper.availableSyncers {
            progress[availableSyncer + "Account"] = false
            progress[availableSyncer + "Challenge"] = false
        }
        
        evaluateAllowContinue()
        
        for availableSyncer in SyncerHelper.availableSyncers {
            SyncerHelper.shared.getSyncer(availableSyncer).getAccount(success: self.accountSuccess, error: self.accountError)
            SyncerHelper.shared.getSyncer(availableSyncer).getChallenge(success: self.challengeSuccess, error: self.challengeError)
        }
    }
    
    /// Callback for synchronization providers that loaded successfully.
    ///
    /// - Parameter account: The account that was loaded.
    /// - Parameter syncerID: The ID of the synchronization provider.
    func accountSuccess(_ account: SyncerAccount, _ syncerID: String) {
        log.verbose("Account resolved for syncer: " + syncerID)
        
        self.accounts[syncerID] = account
        self.progress[syncerID + "Account"] = true
        
        DispatchQueue.main.async {
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).disabled = Condition(booleanLiteral: false)
            
            self.evaluateAllowContinue()
        }
    }
    
    /// Callback for synchronization providers that didn't load because an error occurred.
    ///
    /// - Parameter error: The error that occurred.
    /// - Parameter syncerID: The ID of the synchronization provider.
    func accountError(_ error: Error, _ syncerID: String) {
        log.error("Account error for syncer: " + syncerID)
        
        self.progress[syncerID + "Account"] = true
        
        DispatchQueue.main.async {
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).disabled = Condition(booleanLiteral: true)
            
            self.evaluateAllowContinue()
        }
    }
    
    /// Callback for synchronization provider challenges that loaded successfully.
    ///
    /// - Parameter account: The challenge that was loaded.
    /// - Parameter syncerID: The ID of the synchronization provider.
    func challengeSuccess(_ challenge: SyncerChallenge, _ syncerID: String) {
        log.verbose("Challenge resolved for syncer: " + syncerID)
        
        self.challenges[syncerID] = challenge
        self.progress[syncerID + "Challenge"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
        }
    }
    
    /// Callback for synchronization provider challenges that didn't load because an error occurred.
    ///
    /// - Parameter error: The error that occurred.
    /// - Parameter syncerID: The ID of the synchronization provider.
    func challengeError(_ error: Error, _ syncerID: String) {
        log.error("Challenge error for syncer: " + syncerID)
        
        self.progress[syncerID + "Challenge"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
        }
    }
    
    /// Evaluate if the synchronization providers were loaded and adjust the view accordingly.
    private func evaluateAllowContinue() {
        let allow = !progress.values.contains(false)
        
        continueButton.isEnabled = allow
        continueButton.alpha = CGFloat(allow ? 1 : 0.5)
        viewTitle.text = allow ? "Available storage providers." : "Loading storage providers..."
        
        if (allow) {
            for availableSyncer in SyncerHelper.availableSyncers {
                (self.form.rowBy(tag: availableSyncer) as! ListCheckRow<String>).evaluateDisabled()
            }
            
            synchronizationProviderForm?.selectFirstSyncer()
            dismissNavBarActivity(originalBarButton)
        }
    }
    
    /// Only allow "continue" segues if a synchronization provider is selected
    ///
    /// - Parameter identifier: The string that identifies the triggered segue.
    /// - Parameter sender; The object that initiated the segue.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         if identifier == "SetupPasswordSegue" {
            guard let _ = synchronizationProviderForm!.getSelectedSyncer() else {
                return false
            }
        }
        
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    /// Prepare for the setup encryption segue
    ///
    /// - Parameter segue: The segue object containing information about the view controllers involved in the segue.
    /// - Parameter sender: The object that initiated the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        state(self).syncerID = synchronizationProviderForm!.getSelectedSyncer()!
        state(self).account = self.accounts[state(self).syncerID!]
        state(self).challenge = self.challenges[state(self).syncerID!]
    }

}
