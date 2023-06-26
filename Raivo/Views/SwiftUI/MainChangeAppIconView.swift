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

/// A view that enables the user to change the app icon
struct MainChangeAppIconView: View {
    
    /// An observable that contains the variable content of the view
    @ObservedObject var mainChangeAppIcon: MainChangeAppIconViewObservable

    /// The body of the view
    var body: some View {
        List {
            ForEach(0 ..< mainChangeAppIcon.icons.count, id: \.self) { i in
                Button(action: {
                    let selected = self.mainChangeAppIcon.icons[i]
                    if getAppPrincipal().alternateIconName != selected.getAlternateKey() {
                        getAppPrincipal().setAlternateIconName(selected.getAlternateKey(), completionHandler: {
                            error in
                            if let error = error {
                                log.error(error.localizedDescription)
                            } else {
                                self.mainChangeAppIcon.index = i
                            }
                        })
                    }
                }) {
                    AppIconRow(
                        selectedIndex: self.$mainChangeAppIcon.index,
                        index: i,
                        icon: self.mainChangeAppIcon.icons[i]
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

/// A row that contains an app icon and the title the icon
struct AppIconRow: View {
    
    /// The index of the icon that is currently selected in the list that contains all icon rows
    @Binding var selectedIndex: Int
    
    /// The index of this app icon
    let index: Int
    
    /// An object containing details of the current icon
    let icon: AppIconObject
    
    /// The body of the view
    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: UIImage(named: icon.key) ?? UIImage())
                .resizable()
                .renderingMode(.original)
                .frame(width: 72, height: 72, alignment: .leading)
                .cornerRadius(12.632)
            Text(icon.name)
            Spacer()
            if (index == selectedIndex) {
                Image(systemName: "checkmark")
            }
        }
    }
    
}

/// A preview for the change app icon view
struct MainChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        MainChangeAppIconView(mainChangeAppIcon: MainChangeAppIconViewObservable())
    }
}
