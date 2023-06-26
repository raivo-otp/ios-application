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

import SwiftUI
import CodeScanner
import SwipeCell
import RealmSwift

/// Shows all connected MacOS receivers and enables users to add or remove receivers.
struct MainReceiversView: View {
    
    /// An observable that contains the variable content of the view
    @ObservedObject var receivers = BindableResults<Receiver>(try! RealmHelper.shared.getRealm()!.objects(Receiver.self))
    
    /// A boolean indicating if the user is currently scanning a QR code
    @State var isPresentingScanner: Bool = false
    
    /// The body of the view
    var body: some View {
        listOrPlaceholder
        .sheet(isPresented: $isPresentingScanner) {
            scanner
        }
        .navigationBarItems(trailing: Button(action: {
            self.isPresentingScanner = true
        }) {
            Image(systemName: "plus").imageScale(.large)
        })
    }
    
    /// Basically also the body of the view. This subview shows either a placeholder (if the list is empty), or the list of connected MacOS receivers
    private var listOrPlaceholder: some View {
        if receivers.results.count == 0 {
            return AnyView(VStack(alignment: .center, spacing: 10) {
                Image("vector-empty-set")
                Text("It looks empty around here!").bold().fixedSize(horizontal: false, vertical: true)
                Text("The Raivo MacOS Receiver allows you to push passwords from iOS to MacOS in one tap! Use the plus sign in the top right corner to add your first MacOS receiver by scanning a MacOS receiver QR-code.").fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center).padding())
        }

        return AnyView(
            ScrollView {
                LazyVStack {
                    ForEach(receivers.results.freeze(), id: \.pushToken) { receiver in
                        HStack(alignment: .center, spacing: 15) {
                            Image(systemName: "laptopcomputer.and.iphone")
                                .resizable().scaledToFit()
                            Text(receiver.name)
                            Spacer()
                        }
                        .padding(20)
                        .frame(height: 55)
                        .swipeCell(cellPosition: .right, leftSlot: nil, rightSlot: SwipeCellSlot(slots: [
                            SwipeCellButton(buttonStyle: .titleAndImage,
                                title: "Delete",
                                systemImage: "trash",
                                titleColor: .white,
                                imageColor: .white,
                                view: nil,
                                backgroundColor: .red,
                                action: {
                                    autoreleasepool {
                                        if let realm = try? RealmHelper.shared.getRealm() {
                                            try? RealmHelper.shared.writeBlock(realm) {
                                                realm.delete(realm.objects(Receiver.self).filter("pushToken=%@", receiver.pushToken))
                                            }
                                        }
                                    }
                                },
                                feedback: true
                            )
                        ], slotStyle: .destructive), clip: false)
                        .dismissSwipeCellForScrollViewForLazyVStack()
                    }
                }
            }
        )
    }
    
    /// A view that enables the user to scan MacOS receiver QR codes
    var scanner: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                isPresentingScanner = false
                
                if case let .success(code) = result {
                    var receiver: Receiver? = nil
                    var succesfullySaved = false
                    
                    do {
                        receiver = try ReceiverHelper.shared.getReceiverFromQRCode(code.string)
                    } catch let error {
                        log.error(error.localizedDescription)
                        return BannerHelper.shared.done("Error", error.localizedDescription, duration: 3.0)
                    }

                    autoreleasepool {
                        if let realm = try? RealmHelper.shared.getRealm() {
                            try? RealmHelper.shared.writeBlock(realm) {
                                realm.add(receiver!, update: .modified)
                                succesfullySaved = true
                            }
                        }
                    }
                    
                    if succesfullySaved {
                        BannerHelper.shared.done("Connected", "The MacOS device will now receive OTP's on tap!", duration: 3.0)
                    }
                }
            }
        )
    }
}

/// A preview for the MacOS receivers list
struct MainReceiversView_Previews: PreviewProvider {
    static var previews: some View {
        MainReceiversView()
    }
}
