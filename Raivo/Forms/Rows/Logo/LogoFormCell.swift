//
//  LogoFormCell.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class LogoFormCell: AlertSelectorCell<PasswordLogoTypeFormOption> {
    
    @IBOutlet weak var logoView: UIImageView!
    
    override func setup() {
        super.setup()
    }
    
    override func update() {
        super.update()
        
        logoView?.sd_setImage(
            with: (row as! LogoFormRow).valueURL,
            placeholderImage: UIImage(named: "password-placeholder")
        )
    }
    
}
