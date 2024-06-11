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

import SwiftUI

/// A view that shows an activity indicator (spinner)
struct ActivityIndicator: UIViewRepresentable {
 
    /// A boolean indicating if the indicator is spinning
    @Binding var animate: Bool
    
    /// The style of the indicator
    @Binding var style: UIActivityIndicatorView.Style
    
    /// The color of the indicator
    @Binding var color: UIColor
    
    /// Initialize the activity indicator
    ///
    /// - Parameter animate: A boolean indicating if the indicator is spinning
    /// - Parameter style: The style of the indicator
    /// - Parameter color: The color of the indicator
    init(animate: Binding<Bool> = .constant(true), style: Binding<UIActivityIndicatorView.Style> = .constant(.medium), color: Binding<UIColor> = .constant(.gray)) {
        _animate = animate
        _style = style
        _color = color
    }
    
    /// Creates the view object and configures its initial state.
    ///
    /// - Parameter context: A context structure containing information about the current state of the system.
    /// - Returns: A UIKit view configured with the provided information.
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    ///
    /// - Parameter uiView: A custom view object.
    /// - Parameter context: A context structure containing information about the current state of the system.
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.color = color
        
        animate ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
}

/// A preview for the activity indicator
struct ActivityIndicator_Previews: PreviewProvider {
    
    /// The view to be previewed
    static var previews: some View {
        PreviewWrapper()
    }

    /// A wrapper view containing the activity indicator with initial states
    struct PreviewWrapper: View {
        
        /// A boolean indicating if the indicator is spinning
        @State(initialValue: false) var animate: Bool
        
        /// The style of the indicator
        @State(initialValue: .large) var style:  UIActivityIndicatorView.Style
        
        /// The color of the indicator
        @State(initialValue: .red) var color: UIColor
        
        /// The body of the view
        var body: some View {
            ActivityIndicator(animate: $animate, style: $style, color: $color)
        }
    }
}
