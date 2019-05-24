//
//  GenericUIViewExtension.swift
//  Raivo
//
//  Created by Tijme Gommers on 02/02/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Load a `.xib` file into a UIView class
    ///
    /// - Parameter identifier: The name of the `.xib` file
    /// - Returns: The `.xib` file wrapped in a `UIView`
    public func loadXIBAsUIView(_ identifier: String) -> UIView {
        let nib = UINib(nibName: identifier, bundle: Bundle.main)
        return (nib.instantiate(withOwner: nil, options: nil)[0] as? UIView)!
    }
    
    internal func getAppDelagate() -> AppDelegate {
        return (MyApplication.shared.delegate as! AppDelegate)
    }

}
