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
