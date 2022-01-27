//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit

class PatternImage: UIImageView {
    
    var backupImage: UIImage?
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.forcePattern(providedImage: image)
    }
    
    override convenience init(image: UIImage?, highlightedImage: UIImage?) {
        self.init(image: image, highlightedImage: highlightedImage)
        self.forcePattern(providedImage: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.forcePattern(providedImage: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.forcePattern(providedImage: nil)
    }
    
    private func forcePattern(providedImage: UIImage?) {
        if let image = self.image {
            self.backupImage = image
        }
        
        if let image = providedImage {
            self.backupImage = image
        }
        
        self.image = nil
        
        if let pattern = self.backupImage {
            self.backgroundColor = UIColor(patternImage: pattern)
        }
    }
    
}
