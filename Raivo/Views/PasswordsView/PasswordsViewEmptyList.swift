//
//  PasswordsViewEmptyList.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import SVGKit

class PasswordsViewEmptyList: UIView {
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint! {
        didSet {
            adjustConstraintToKeyboard()
        }
    }
    
    @IBOutlet weak var viewEmptyImage: SVGKFastImageView! {
        didSet {
            let url = Bundle.main.url(forResource: "empty", withExtension: "svg")
            viewEmptyImage.image = SVGKImage(contentsOf: url)
        }
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
}
