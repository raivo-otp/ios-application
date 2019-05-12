//
//  IconFormSelectorViewEmptyList.swift
//  Raivo
//
//  Created by Tijme Gommers on 11/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
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
