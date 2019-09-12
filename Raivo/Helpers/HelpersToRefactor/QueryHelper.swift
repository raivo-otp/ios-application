//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import RealmSwift

class QueryHelper {
    
    static func passwordSearch(_ search: String) -> NSPredicate {
        var values: [String] = []
        var query: [String] = []
        
        for value in search.split(separator: " ") {
            query.append("(issuer CONTAINS[cd] %@ OR account CONTAINS[cd] %@)")
            values.append(String(value))
            values.append(String(value))
        }
        
        if query.count == 0 {
            return NSPredicate(value: true)
        }
        
        return NSPredicate(format: query.joined(separator: " AND "), argumentArray: values)
    }
    
}
