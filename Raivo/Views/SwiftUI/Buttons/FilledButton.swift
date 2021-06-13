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

struct FilledButton: View {
    
    let title: String
    
    let action: () -> Void
    
    @Binding var busy: Bool
    
    init(_ title: String, busy: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.title = title
        self.action = action
        _busy = busy
    }

    var body: some View {
        Button(action: action) {
            HStack {
                ActivityIndicator(animate: $busy, color: .constant(.white))
                    .frame(width: busy ? nil : 0)
                Text(title)
                    .font(.system(size: 18))
                    .bold()
            }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(8)
                .disabled(busy)
        }
    }
}

struct FilledButton_Previews: PreviewProvider {
    static var previews: some View {
        FilledButton("Download") {}
    }
}
