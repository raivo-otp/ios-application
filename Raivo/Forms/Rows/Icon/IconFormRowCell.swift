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
        
        guard let value = iconValue, iconValue?.count ?? 0 > 0 else {
            iconView.image = UIImage(named: "vector-empty-item")
            return
        }
        
        let url = URL(string: AppHelper.iconsURL + value)
        
        iconView?.sd_setImage(with: url, placeholderImage: UIImage(named: "vector-empty-item"))
        iconView.image = iconView.image?.withIconEffect
    }
    
}
