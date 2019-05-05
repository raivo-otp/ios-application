//
//  LogoFormViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Eureka

public class LogoFormViewController: UIViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Logo"
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        row.value = Bundle.main.url(forResource: "twitter", withExtension: "svg", subdirectory: "Issuers/vectors")
//        onDismissCallback?(self)
    }
}
