//
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
import RealmSwift

class BindableResults<Element>: ObservableObject where Element: RealmSwift.RealmCollectionValue {

    var results: Results<Element>
        
    private var token: NotificationToken!

    init(_ results: Results<Element>) {
        self.results = results
        
        token = results.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    deinit {
        token.invalidate()
    }
    
}
