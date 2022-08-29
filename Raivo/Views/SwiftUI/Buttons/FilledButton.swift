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

/// A filled button with a 'tint' background by default' (that has a view as input)
struct FilledButton<Content: View>: View {
    
    /// The text in the button
    let content: Content
    
    /// The action to take on tap
    let action: () -> Void
    
    /// An progress indicator is shown if busy has a positive value
    @Binding var busy: Bool
    
    /// Initialize the button with a title, busy state and tab action
    ///
    /// - Parameter content: The text in the button
    /// - Parameter busy: Positive if a progress indicator should be shown
    /// - Parameter action: The action (closure) to execute on tab
    init(@ViewBuilder _ content: () -> Content, busy: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.content = content()
        self.action = action
        _busy = busy
    }

    /// The body of the view
    var body: some View {
        Button(action: action) {
            HStack {
                ActivityIndicator(animate: $busy, color: .constant(.white))
                    .frame(width: busy ? nil : 0)
                self.content
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

/// A filled button with a 'tint' background by default' (that has text as input)
struct FilledButtonText: View {
    
    /// The text in the button
    let title: String
    
    /// The action to take on tap
    let action: () -> Void
    
    /// An progress indicator is shown if busy has a positive value
    @Binding var busy: Bool
    
    /// Initialize the button with a title, busy state and tab action
    ///
    /// - Parameter content: The text in the button
    /// - Parameter busy: Positive if a progress indicator should be shown
    /// - Parameter action: The action (closure) to execute on tab
    init(_ title: String, busy: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.title = title
        self.action = action
        _busy = busy
    }
    
    /// The body of the view
    var body: some View {
        FilledButton({
            Text(title)
                .font(.system(size: 18))
                .bold()
        }, busy: $busy, action: action)
    }
}

/// A preview for the filled buttons
struct FilledButton_Previews: PreviewProvider {
    static var previews: some View {
        FilledButtonText("Download") {}
        
        Divider()
        
        FilledButton({
            Text("Download")
                .font(.system(size: 18))
                .bold()
        }) {}
        
        Divider()
        
        FilledButton({
            HStack {
                Text("Download")
                    .font(.system(size: 18))
                    .bold()
                Spacer()
                Text("$ 1.99")
                    .font(.system(size: 18))
                    .bold()
            }
        }) {}
    }
}
