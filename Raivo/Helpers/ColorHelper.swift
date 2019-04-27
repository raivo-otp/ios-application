//
//  ColorHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 15/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit

class ColorHelper {
    
    public static func getTint() -> UIColor {
        return UIColor.init(hex: "#e80d33")
    }
    
    public static func getLightBackground() -> UIColor {
        return UIColor.init(hex: "ececec").withAlphaComponent(0.95)
    }
    
}
