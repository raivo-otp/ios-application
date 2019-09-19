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

/// A helper class for managing CoreImage filters depending on the user interface style.
class ImageFilterHelper {
    
    /// The singleton instance for the ImageFilterHelper
    public static let shared = ImageFilterHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Get an SDWebImage pipeline of active CoreImageFilter transformers.
    ///
    /// - Parameter sender: The user interface style of the sender will be used to determine which transformers to use.
    /// - Returns: A pipeline of CoreImageFilter transformers.
    public func getCurrentTransformerPipeline(_ sender: UITraitEnvironment) -> SDImagePipelineTransformer {
        var transformers: [SDImageTransformer] = []
        
        if #available(iOS 12.0, *) {
            switch sender.traitCollection.userInterfaceStyle {
            case .dark:
                if let filter = getDarkModeFilter() {
                    transformers.append(SDImageFilterTransformer(filter: filter))
                }
            default:
                break
            }
        }
        
        if let filter = getIconEffectFilter() {
            transformers.append(SDImageFilterTransformer(filter: filter))
        }
        
        return SDImagePipelineTransformer(transformers: transformers)
    }
    
    /// An image filter that can be used if Dark Mode is enabled. The filter reduces dark colors (e.g. converts black to grey).
    ///
    /// - Returns: The CoreImageFilter.
    private func getDarkModeFilter() -> CIFilter? {
        let colorClampParams : [String : AnyObject] = [
            "inputMinComponents": CIVector(x: 0.05, y: 0.05, z: 0.05, w: 0.0),
            "inputMaxComponents" : CIVector(x: 0.92, y: 0.92, z: 0.92, w: 0.92)
        ]

        return CIFilter(name: "CIColorClamp", parameters: colorClampParams)!
    }
    
    /// Depending on the user's settings, an icon effect filter is returned.
    ///
    /// - Returns: The CoreImageFilter, if any.
    private func getIconEffectFilter() -> CIFilter? {
        let effect = getAppDelegate().getIconEffect()

        switch effect {
        case MiscellaneousIconsEffectFormOption.OPTION_GRAYSCALE.value:
            return applying(saturation: 0)
        default:
            return nil
        }
    }

    /// A saturation filter that can make the image grayscale.
    ///
    /// - Parameter saturation: How much saturation to apply (1.0 is all colors, 0.0 is grayscale).
    /// - Returns: The CoreImageFilter, if any.
    private func applying(saturation value: NSNumber) -> CIFilter? {
        return CIFilter(name: "CIColorControls", parameters: [kCIInputSaturationKey: value])
    }
    
}
