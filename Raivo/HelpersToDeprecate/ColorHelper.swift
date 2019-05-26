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

class ColorHelper {
    
    public static func getTint() -> UIColor {
        return UIColor.init(hex: "#e80d33")
    }
    
    public static func getLightBackground() -> UIColor {
        return UIColor.init(hex: "ececec").withAlphaComponent(0.95)
    }
    
}
