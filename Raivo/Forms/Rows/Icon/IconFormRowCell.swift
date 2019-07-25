//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
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
        
        let iconValue = (row as! IconFormRow).iconValue
        
        if iconValue == nil {
            iconView.image = UIImage(named: "password-placeholder")
        } else {
            let url = URL(string: AppHelper.iconsURL + (iconValue ?? ""))
            
            iconView?.sd_setImage(with: url, placeholderImage: UIImage(named: "password-placeholder"))
            iconView.image = iconView.image?.withIconEffect
        }
    }
    
}
