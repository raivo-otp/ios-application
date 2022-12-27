//
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
import SwiftyStoreKit
import StoreKit

/// An Apple Push Notification Token that can be observed
class MainDonateViewObservable: ObservableObject {
    
    /// The product ID's
    public static var PRODUCT_IDS: Set<String> = [
        "raivo.otp.ios.tip.small",
        "raivo.otp.ios.tip.large",
        "raivo.otp.ios.tip.hosting",
        "raivo.otp.ios.tip.license"
    ]
    
    /// The purchases
    @Published var tips: [SKProduct] = []
    
    /// Fetch all products on initialize
    init() {
        fetchTips()
    }
    
    /// Fetch all available tips
    func fetchTips() {
        #if DEBUG
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let retrievedProducts = [
                SKProduct(
                    identifier: "raivo.otp.ios.tip.small",
                    title: "Domain-sized tip",
                    description: "Keep raivo-otp.com (domain) registered for one more year.",
                    price: 1.99
                ),
                SKProduct(
                    identifier: "raivo.otp.ios.tip.large",
                    title: "Domain-sized tip (x5)",
                    description: "Keep raivo-otp.com (domain) registered for another five years.",
                    price: 9.99
                ),
                SKProduct(
                    identifier: "raivo.otp.ios.tip.hosting",
                    title: "Hosting-sized tip",
                    description: "Donate a year of hosting for the push notification server. 🙈",
                    price: 49.99
                ),
                SKProduct(
                    identifier: "raivo.otp.ios.tip.license",
                    title: "License-sized tip",
                    description: "Donate the cost of the annual developer license. 🚀",
                    price: 99.99
                )
            ]
            
            self.tips = Array(retrievedProducts).sorted(by: { leftProduct, rightProduct in
                leftProduct.price.decimalValue < rightProduct.price.decimalValue
            })
//        }
        #else
        SwiftyStoreKit.retrieveProductsInfo(MainDonateViewObservable.PRODUCT_IDS) { result in
            guard result.error == nil else {
                return
            }
            
            self.tips = Array(result.retrievedProducts).sorted(by: { leftProduct, rightProduct in
                leftProduct.price.decimalValue < rightProduct.price.decimalValue
            })
        }
        #endif
    }
   
}
