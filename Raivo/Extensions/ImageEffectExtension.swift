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
import SDWebImage

extension UIImage {
    
    var enabledTransformers: SDImagePipelineTransformer {
        var pipeline: [SDImageTransformer] = []
        
        if #available(iOS 12.0, *) {
            if (traitCollection.responds(to: #selector(getter: UITraitCollection.userInterfaceStyle))) {
               switch traitCollection.userInterfaceStyle {
               case .light:
                   log.debug("UserInterfaceStyle: light")
               case .dark:
                log.debug("UserInterfaceStyle: dark")
                   pipeline.append(SDImageFilterTransformer(filter: darkModeFilter))
               case .unspecified:
                    log.debug("UserInterfaceStyle: unspecified")
               }
            }
        }
        
        if let filter = enabledFilter {
            pipeline.append(SDImageFilterTransformer(filter: filter))
        }
        
        return SDImagePipelineTransformer(transformers: pipeline)
    }
        
    var enabledFilter: CIFilter? {
        let effect = getAppDelegate().getIconEffect()

        switch effect {
        case MiscellaneousIconsEffectFormOption.OPTION_GRAYSCALE.value:
            return applying(saturation: 0)
        default:
            return nil
        }
    }
    
    var darkModeFilter: CIFilter {
        let colorClampParams : [String : AnyObject] = [
            "inputMinComponents": CIVector(x: 0.05, y: 0.05, z: 0.05, w: 0.0),
            "inputMaxComponents" : CIVector(x: 0.92, y: 0.92, z: 0.92, w: 0.92)
        ]
        
        return CIFilter(name: "CIColorClamp", parameters: colorClampParams)!
    }
    
    func applying(saturation value: NSNumber) -> CIFilter? {
        return CIFilter(name: "CIColorControls", parameters: [kCIInputSaturationKey: value])
    }

}
