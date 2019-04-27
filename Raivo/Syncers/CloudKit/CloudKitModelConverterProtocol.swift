//
//  CloudKitModelConverterProtocol.swift
//  Raivo
//
//  Created by Tijme Gommers on 19/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitModelConverterProtocol: BaseClass {
    
    static func getLocal(_ record: CKRecord) -> Password?
    
    static func getLocalCopy(_ record: CKRecord, syncedCorrectly: Bool) -> Password
    
    static func getRemote(_ password: Password) -> CKRecord
    
}
