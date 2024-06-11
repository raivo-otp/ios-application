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
