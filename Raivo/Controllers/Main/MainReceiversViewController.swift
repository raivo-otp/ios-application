//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import UIKit
import SwiftUI

class MainReceiversViewController: UIHostingController<AnyView> {
    
    required init?(coder aDecoder: NSCoder) {
        let root = AnyView(MainReceiversView())
        
        super.init(coder: aDecoder, rootView: root)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
