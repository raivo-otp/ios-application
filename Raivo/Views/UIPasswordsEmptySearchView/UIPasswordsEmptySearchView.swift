//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

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
