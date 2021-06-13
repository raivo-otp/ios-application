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

struct ActivityIndicator: UIViewRepresentable {
 
    @Binding var animate: Bool
    
    @Binding var style: UIActivityIndicatorView.Style
    
    @Binding var color: UIColor
    
    init(
        animate: Binding<Bool> = .constant(true),
        style: Binding<UIActivityIndicatorView.Style> = .constant(.medium),
        color: Binding<UIColor> = .constant(.gray)
    ) {
        _animate = animate
        _style = style
        _color = color
    }
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.color = color
        
        animate ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        
        @State(initialValue: false) var animate: Bool
        
        @State(initialValue: .large) var style:  UIActivityIndicatorView.Style
        
        @State(initialValue: .red) var color: UIColor

        var body: some View {
            ActivityIndicator(animate: $animate, style: $style, color: $color)
        }
    }
}
