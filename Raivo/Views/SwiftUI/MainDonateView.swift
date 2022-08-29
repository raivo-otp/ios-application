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
import SwiftUI
import SwiftyStoreKit
import StoreKit

/// Shows a view for donating a specific in-app purchase
struct MainDonateView: View {
    
    /// The in-app purchases
    @ObservedObject var products = MainDonateViewObservable()
    
    /// Identifier of payment that was initiated by user
    @State var paymentInitiated: String? = nil
    
    /// dentifier of payment that was made by user
    @State var paymentSucceeded: String? = nil
    
    /// Payment error
    @State var paymentError: String? = nil
    
    /// Initiate the payment process for the given tip
    ///
    /// - Parameter tip: The tip to pay for
    private func startPayment(_ tip: SKProduct) {
        SwiftyStoreKit.purchaseProduct(tip.productIdentifier, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let product):
                paymentSucceeded = product.productId
            case .error(let error):
                paymentInitiated = nil

                switch error.code {
                case .unknown:
                    paymentError = "An unknown error occurred during the payment."
                case .clientInvalid:
                    paymentError = "You are not allowed to make this payment."
                case .paymentInvalid:
                    paymentError = "The purchase identifier was invalid."
                case .paymentNotAllowed:
                    paymentError = "This device is not allowed to make a payment."
                case .storeProductNotAvailable:
                    paymentError = "This tip is not available at the moment."
                case .cloudServicePermissionDenied:
                    paymentError = "Access to cloud service information is not allowed."
                case .cloudServiceNetworkConnectionFailed:
                    paymentError = "Could not connect to the internet."
                case .cloudServiceRevoked:
                    paymentError = "User has revoked permission to use this cloud service"
                case .paymentCancelled:
                    break
                default:
                    paymentError = (error as NSError).localizedDescription
                }
            case .deferred(purchase: _):
                break
            }
        }
    }

    /// The actual view shown when someone clicks on the donate settings button
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if paymentSucceeded != nil {
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "hands.sparkles.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50.0, height: 50.0)
                    Text("That's very generous.\nThank you so much!").multilineTextAlignment(.center)
                    Text("Regards, Tijme Gommers.").foregroundColor(.secondary)
                }.padding(20)
            } else if paymentError != nil {
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "xmark.octagon.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50.0, height: 50.0)
                    Text(paymentError!).multilineTextAlignment(.center)
                    Button("Try Again") {
                        paymentError = nil
                        paymentInitiated = nil
                    }
                }.padding(20)
            } else if products.tips.isEmpty {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Donating helps me keep Raivo alive!")
                        Divider()
                        ForEach(products.tips, id: \.self) { tip in
                            VStack(alignment: .leading, spacing: 8) {
                                FilledButton({
                                    HStack {
                                        Text(tip.localizedTitle)
                                            .font(.system(size: 18))
                                            .bold()
                                        Spacer()
                                        Text(tip.localizedPrice ?? "")
                                            .font(.system(size: 18))
                                            .bold()
                                    }
                                }, busy: .constant(paymentInitiated == tip.productIdentifier)) {
                                    paymentInitiated = tip.productIdentifier
                                    startPayment(tip)
                                }
                                Text(tip.localizedDescription)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }.padding(20)
                }
            }
        }
    }
    
}

/// Preview the donate view in dark mode
struct MainDonateViewDark_Previews: PreviewProvider {
    static var previews: some View {
        MainDonateView().preferredColorScheme(.dark)
    }
}

/// Preview the donate view in light mode
struct MainDonateViewLight_Previews: PreviewProvider {
    static var previews: some View {
        MainDonateView().preferredColorScheme(.light)
    }
}
