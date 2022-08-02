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

class SyncerAccount {
    
    let name: String

    let identifier: String
    
    init(name: String, identifier: String) {
        self.name = name
        self.identifier = identifier
    }
    
}
