//
//  SecondaryButtonView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/6/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SecondaryButtonView: View {
    
    @Binding var tapped: Bool
    var icon = "pencil"
    var color = Color.blue
    var offsetX = 0
    var offsetY = 0
    var delay = 0.0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.body)
        }
        .padding()
        .background(color)
        .mask(Circle())
        .offset(x: tapped ? CGFloat(offsetX) : 0, y: tapped ? CGFloat(offsetY) : 0)
        .scaleEffect(tapped ? 1 : 0.5)
        .animation(Animation.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0).delay(Double(delay)))
    }
}
