//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation

class SyncerChallenge {
    
    let challenge: String?
    
    init(challenge: String?) {
        self.challenge = challenge
    }
    
    func hasChallenge() -> Bool {
        return challenge != nil
    }
    
}
