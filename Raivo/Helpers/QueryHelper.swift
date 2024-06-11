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
import RealmSwift

/// A helper class for building SQLite (realm) queries
class QueryHelper {
    
    /// The singleton instance for the QueryHelper
    public static let shared = QueryHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Build a "LIKE" statement that searches for the given needle
    ///
    /// - Parameter needle: The string (needle) to search for in the database (haystack)
    /// - Returns: A NSPredicate that can be used in Realm queries
    public func passwordSearch(_ needle: String) -> NSPredicate {
        var values: [String] = []
        var query: [String] = []
        
        for value in needle.split(separator: " ") {
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
