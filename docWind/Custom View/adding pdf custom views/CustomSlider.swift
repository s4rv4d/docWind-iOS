//
//  CustomSlider.swift
//  docWind
//
//  Created by Sarvad Shetty on 03/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI


struct CustomSlider: View {
    
    @Binding var value: CGFloat
    
    @State var lastOffset: CGFloat = 0
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    var range: ClosedRange<CGFloat>
    var leadingOffset: CGFloat = 5
    var trailingOffset: CGFloat = 5
    
    var knobSize: CGSize = CGSize(width: 15, height: 15)
    
    let trackGradient = LinearGradient(gradient: Gradient(colors: [.blue, .gray]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: self.$value.wrappedValue.map(from: self.range, to: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset)), height: 4)
                        .foregroundColor(Color(tintColor))
                    Rectangle()
                        .frame(height: 4)
                        .foregroundColor(Color.secondarySystemGroupedBackground)
                }
                HStack {
                    RoundedRectangle(cornerRadius: .infinity)
                        .frame(width: self.knobSize.width, height: self.knobSize.height)
                        .foregroundColor(.primary)
                        .offset(x: self.$value.wrappedValue.map(from: self.range, to: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset)))
                        .shadow(radius: 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    
                                    if abs(value.translation.width) < 0.1 {
                                        self.lastOffset = self.$value.wrappedValue.map(from: self.range, to: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset))
                                    }
                                    
                                    let sliderPos = max(0 + self.leadingOffset, min(self.lastOffset + value.translation.width, geometry.size.width - self.knobSize.width - self.trailingOffset))
                                    let sliderVal = sliderPos.map(from: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset), to: self.range)
                                    
                                    self.value = sliderVal
                                }
                                
                    )
                    Spacer()
                }
            }
        }
    }
}

struct CustomSlider_Previews: PreviewProvider {
    static var previews: some View {
        CustomSlider(value: .constant(0.5), range: .init(uncheckedBounds: (lower: 0, upper: 1)))
            .preferredColorScheme(.dark)
    }
}
