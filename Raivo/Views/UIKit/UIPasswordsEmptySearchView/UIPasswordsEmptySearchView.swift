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

class UIPasswordsEmptySearchView: UIView {
    
    @IBOutlet weak var wrapper: UIView!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let parent = superview else {
            return
        }

        let paddingTop = parent.safeAreaInsets.top
        let paddingBottom = parent.safeAreaInsets.bottom
        
        let topCon = wrapper.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop)
        topCon.priority = UILayoutPriority(1000.0)
        topCon.isActive = true
        
        let bottomCon = wrapper.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -paddingBottom)
        bottomCon.priority = UILayoutPriority(1000.0)
        bottomCon.isActive = true
        
        layoutIfNeeded()
    }
    
}
