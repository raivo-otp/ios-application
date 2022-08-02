//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import UIKit

class IconFormSelectorViewEmptySearch: UIView {

    @IBAction func addIcon(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/raivo-otp/issuer-icons")!, options: [:])
    }
    
}
