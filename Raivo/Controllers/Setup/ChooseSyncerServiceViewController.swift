//
//  ChooseSyncerServiceViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/01/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Spring
import Eureka

class ChooseSyncerServiceViewController: FormViewController {
    
    private var raivoForm: ProvidersForm?
    
    public var accounts: [String: SyncerAccount] = [:]
    
    public var challenges: [String: SyncerChallenge] = [:]
    
    private var progress: [String: Bool] = [:]
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var viewDescription: SpringLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raivoForm = ProvidersForm(form, controller: self)
        
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
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).evaluateDisabled()
        }
    }
    
    func accountError(_ error: Error, _ syncerID: String) {
        self.progress[syncerID + "Account"] = true
        
        DispatchQueue.main.async {
            self.evaluateAllowContinue()
            
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).disabled = Condition(booleanLiteral: true)
            (self.form.rowBy(tag: syncerID) as! ListCheckRow<String>).evaluateDisabled()
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
            raivoForm?.selectFirstSyncer()
            dismissNavBarActivity()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         if identifier == "DatabaseEncryptionSegue" {
            guard let _ = raivoForm!.getSelectedSyncer() else {
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DatabaseEncryptionSegue" {
            if let destination = segue.destination as? ChooseEncryptionKeyViewController {
                KeychainHelper.settings().set(string: raivoForm!.getSelectedSyncer()!, forKey: KeychainHelper.KEY_SYNCHRONIZATION_PROVIDER)
                destination.account = self.accounts[raivoForm!.getSelectedSyncer()!]
                destination.challenge = self.challenges[raivoForm!.getSelectedSyncer()!]
            }
        }
    }

}
