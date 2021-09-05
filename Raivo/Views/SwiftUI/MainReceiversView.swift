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

import SwiftUI
import CodeScanner
import SwipeCell
import RealmSwift

struct MainReceiversView: View {
    
    @ObservedObject var receivers = BindableResults<Receiver>(RealmHelper.shared.getRealm()!.objects(Receiver.self))
    
    @State var isPresentingScanner: Bool = false
    
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
                                        if let realm = RealmHelper.shared.getRealm() {
                                            try! realm.write {
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
    
    var scanner: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                isPresentingScanner = false
                
                if case let .success(code) = result {
                    var receiver: Receiver? = nil
                    
                    do {
                        receiver = try ReceiverHelper.shared.getReceiverFromQRCode(qrcode: code)
                    } catch let error {
                        log.error(error.localizedDescription)
                        return BannerHelper.shared.done("Error", error.localizedDescription, duration: 3.0)
                    }

                    autoreleasepool {
                        if let realm = RealmHelper.shared.getRealm() {
                            try! realm.write {
                                realm.add(receiver!, update: .modified)
                            }
                        }
                    }
                    
                    BannerHelper.shared.done("Connected", "The MacOS device will now receive OTP's on tap!", duration: 3.0)
                }
            }
        )
    }
}

struct MainReceiversView_Previews: PreviewProvider {
    static var previews: some View {
        MainReceiversView()
    }
}
