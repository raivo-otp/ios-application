//
//  LoadingUIViewExtension.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Show a loading animation on the right of the navbar
    public func displayNavBarActivity() -> UIBarButtonItem? {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.startAnimating()
        let item = UIBarButtonItem(customView: indicator)
        
        let backup = self.navigationItem.rightBarButtonItem
        self.navigationItem.rightBarButtonItem = item
        return backup
    }
    
    /// Dismiss the loading animation on the right of the navbar
    public func dismissNavBarActivity() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    /// Dismiss the loading animation on the right of the navbar
    public func dismissNavBarActivity(_ backup: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = backup
    }

}
