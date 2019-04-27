//
//  SyncerAccount.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class SyncerAccount {
    
    let serviceName: String
    let accountName: String
    let accountIdentifier: String
    
    init(serviceName: String, accountName: String, accountIdentifier: String) {
        self.serviceName = serviceName
        self.accountName = accountName
        self.accountIdentifier = accountIdentifier
    }
    
}
