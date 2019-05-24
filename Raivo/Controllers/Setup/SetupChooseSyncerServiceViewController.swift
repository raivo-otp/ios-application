//
//  SetupChooseSyncerServiceViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/01/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Spring
import Eureka

class SetupChooseSyncerServiceViewController: FormViewController {
    
    private var synchronizationProviderForm: SynchronizationProviderForm?
    
    public var accounts: [String: SyncerAccount] = [:]
    
    public var challenges: [String: SyncerChallenge] = [:]
    
    private var progress: [String: Bool] = [:]
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var viewDescription: SpringLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        synchronizationProviderForm = SynchronizationProviderForm(form).build()
        
        continueButton.setTitle("Hold on!", for: UIControl.State.disabled)
        
        resolveSyncers()
    }
    
    private func resolveSyncers() {
        let _ = displayNavBarActivity()
        
        for availableSyncer in SyncerHelper.availableSyncers {
            progress[availableSyncer + "Account"] = false
            progress[availableSyncer + "Challenge"] = false
        }
        
        evaluateAllowContinue()
        
        for availableSyncer in SyncerHelper.availableSyncers {
            SyncerHelper.getSyncer(availableSyncer).getAccount(success: self.accountSuccess, error: self.accountError)
            SyncerHelper.getSyncer(availableSyncer).getChallenge(success: self.challengeSuccess, error: self.challengeError)
        }
    }
    
    func accountSuccess(_ account: SyncerAccount, _ syncerID: String) {
        self.accounts[syncerID] = account
        self.progress[syncerID + "Account"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
            
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).disabled = Condition(booleanLiteral: false)
        }
    }
    
    func accountError(_ error: Error, _ syncerID: String) {
        self.progress[syncerID + "Account"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
            
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).disabled = Condition(booleanLiteral: true)
        }
    }
    
    func challengeSuccess(_ challenge: SyncerChallenge, _ syncerID: String) {
        self.challenges[syncerID] = challenge
        self.progress[syncerID + "Challenge"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
        }
    }
    
    func challengeError(_ error: Error, _ syncerID: String) {
        self.progress[syncerID + "Challenge"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
        }
    }
    
    private func evaluateAllowContinue() {
        let allow = !progress.values.contains(false)
        
        continueButton.isEnabled = allow
        continueButton.alpha = CGFloat(allow ? 1 : 0.5)
        viewTitle.text = allow ? "Synchronization providers" : "Loading providers..."
        
        if (allow) {
            for availableSyncer in SyncerHelper.availableSyncers {
                (self.form.rowBy(tag: availableSyncer) as! ListCheckRow<String>).evaluateDisabled()
            }
            
            synchronizationProviderForm?.selectFirstSyncer()
            dismissNavBarActivity()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         if identifier == "DatabaseEncryptionSegue" {
            guard let _ = synchronizationProviderForm!.getSelectedSyncer() else {
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DatabaseEncryptionSegue" {
            if let destination = segue.destination as? SetupChooseEncryptionKeyViewController {
                let selectedSyncer = synchronizationProviderForm!.getSelectedSyncer()!
                
                StorageHelper.setSynchronizationProvider(selectedSyncer)
                StorageHelper.setSynchronizationAccountIdentifier(self.accounts[selectedSyncer]!.identifier)
                getAppDelagate().syncerAccountIdentifier = self.accounts[selectedSyncer]!.identifier
                
                destination.account = self.accounts[selectedSyncer]
                destination.challenge = self.challenges[selectedSyncer]
            }
        }
    }

}
