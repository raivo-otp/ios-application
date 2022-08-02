//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

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
        
        traitCollectionDidChange(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let iconValue = (row as! IconFormRow).iconValue
        
        guard let value = iconValue, iconValue?.count ?? 0 > 0 else {
            iconView.image = UIImage(named: "vector-empty-item")
            return
        }
        
        iconView.sd_setImage(
            with: URL(string: AppHelper.iconsURL + value),
            placeholderImage: UIImage(named: "vector-empty-item"),
            context: [.imageTransformer: ImageFilterHelper.shared.getCurrentTransformerPipeline(self)]
        )
    }
    
}
