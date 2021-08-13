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

struct MainChangeAppIconView: View {
    
    @ObservedObject var mainChangeAppIcon: MainChangeAppIconViewObservable
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10, content: {
                ForEach(0 ..< mainChangeAppIcon.icons.count) { i in
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
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

struct AppIconRow: View {
    
    @Binding var selectedIndex: Int
    
    let index: Int
    
    let icon: AppIconObject
    
    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: UIImage(named: icon.key ?? "") ?? UIImage())
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

struct MainChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        MainChangeAppIconView(mainChangeAppIcon: MainChangeAppIconViewObservable())
    }
}
