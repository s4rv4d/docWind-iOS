//
//  CaptureButtonView.swift
//  Photostat
//
//  Created by Sarvad shetty on 10/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CaptureButtonView: View {
    
    // MARK: - @State view modifiers
    @State private var animationAmount: CGFloat = 1
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    var body: some View {
        Image(systemName: "camera").font(.body)
            .padding(25)
            .background(Color(tintColor))
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.primary, lineWidth: 3)
//                    .scaleEffect(animationAmount)
//                    .opacity(Double(2 - animationAmount))
//                    .animation(Animation.easeOut(duration: 1)
//                        .repeatForever(autoreverses: false))

        )
        .onAppear
            {
                self.animationAmount = 2
        }
    }
}

struct CaptureButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureButtonView()
    }
}
