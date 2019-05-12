//
//  IconFormCell.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class IconFormRowCell: AlertSelectorCell<PasswordIconTypeFormOption> {
    
    @IBOutlet weak var iconView: UIImageView!
    
    override func setup() {
        super.setup()
    }
    
    override func update() {
        super.update()
        
        let url = URL(string: AppHelper.iconsURL + ((row as! IconFormRow).iconValue ?? ""))
        
        iconView?.sd_setImage(with: url, placeholderImage: UIImage(named: "password-placeholder"))
        iconView.image = iconView.image?.withIconEffect
    }
    
}
