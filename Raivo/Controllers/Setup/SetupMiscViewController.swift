//
//  SetupMiscViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 12/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Eureka
import CloudKit
import RealmSwift

class SetupMiscViewController: FormViewController {
    
    private var miscellaneousForm: MiscellaneousForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form).build(controller: self).ready()
    }
    
}
