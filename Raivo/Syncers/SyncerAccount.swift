//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation

class SyncerAccount {
    
    let name: String

    let identifier: String
    
    init(name: String, identifier: String) {
        self.name = name
        self.identifier = identifier
    }
    
}
