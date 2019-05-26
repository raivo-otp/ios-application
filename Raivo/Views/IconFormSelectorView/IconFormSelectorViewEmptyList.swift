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
import Spring

class IconFormSelectorViewEmptyList: UIView {
    
    private var loadingImageAnimated: SpringImageView?

    @IBOutlet weak var loadingImage: SpringImageView! {
        set {
            self.loadingImageAnimated = newValue
            self.loadingImageAnimated!.animation = "pop"
            self.loadingImageAnimated!.duration = CGFloat(1.6)
            self.loadingImageAnimated!.repeatCount = Float.infinity
            self.loadingImageAnimated!.animate()
        }
        get {
            return self.loadingImageAnimated!
        }
    }
    
    
}
