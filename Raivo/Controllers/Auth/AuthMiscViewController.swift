//
//  AuthMiscViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 20/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Eureka
import CloudKit
import RealmSwift

class AuthMiscViewController: FormViewController {
    
    private var raivoForm: MiscForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raivoForm = MiscForm(form)
        raivoForm!.load(controller: self, authenticated: false)
    }

}
