//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
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
		let iconType = (row as! IconFormRow).iconType
        let iconValue = (row as! IconFormRow).iconValue
        
        guard let value = iconValue, iconValue?.count ?? 0 > 0 else {
            iconView.image = UIImage(named: "vector-empty-item")
            return
        }
        
		if iconType == PasswordIconTypeFormOption.OPTION_RAIVO_REPOSITORY.value {
			iconView.sd_setImage(
				with: URL(string: AppHelper.iconsURL + value),
				placeholderImage: UIImage(named: "vector-empty-item"),
				context: [.imageTransformer: ImageFilterHelper.shared.getCurrentTransformerPipeline(self)]
			)
		} else {
			iconView.sd_setImage(
				with: URL(string: value),
				placeholderImage: UIImage(named: "vector-empty-item"),
				context: [.imageTransformer: ImageFilterHelper.shared.getCurrentTransformerPipeline(self)]
			)
			iconView.layer.cornerRadius = iconView.bounds.height/2
			iconView.clipsToBounds = true
		}
    }
    
}
