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
    
    private var miscellaneousForm: MiscellaneousForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form).build(controller: self).ready()
    }

}
