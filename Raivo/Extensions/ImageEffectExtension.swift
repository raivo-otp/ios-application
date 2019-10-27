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
                   log.info("light")
               case .dark:
                   log.info("dark")
                   pipeline.append(SDImageFilterTransformer(filter: darkModeFilter))
               case .unspecified:
                   log.info("unspecified")
               }
      
            } else {
                 log.info("RETURNING")
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
//        case MiscellaneousIconsEffectFormOption.OPTION_RED_TINT.value:
//            return fillWithColor(UIColor.raivo.tint)
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
        
    //    func applying(_ maskColor: UIColor) -> UIImage? {
    //        let maskImage = cgImage!
    //
    //        let width = size.width
    //        let height = size.height
    //        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
    //
    //        let colorSpace = CGColorSpaceCreateDeviceRGB()
    //        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    //        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
    //
    //        context.clip(to: bounds, mask: maskImage)
    //        context.setFillColor(color.cgColor)
    //        context.fill(bounds)
    //
    //        if let cgImage = context.makeImage() {
    //            let coloredImage = UIImage(cgImage: cgImage)
    //            return coloredImage
    //        } else {
    //            return nil
    //        }
    //    }
    
}
