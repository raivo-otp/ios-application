//
//  QueryHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 24/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
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
