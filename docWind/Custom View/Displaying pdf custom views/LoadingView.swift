//
//  LoadingView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/12/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
//                    .blur(radius: self.isShowing ? 3 : 0)
                    .blur(radius: self.isShowing ? 2 : 0)
                    
                if self.isShowing {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
    //                    Text("Loading...")
                        ActivityIndicator(isAnimating: self.$isShowing).padding(.top)
                        VStack(spacing: 5) {
                            Text("This may take a few minutes")
                                .font(.body)
                            Text("Please wait")
                                .font(.caption)
                            Text("Bigger pdfs may take longer to scan")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top)
                        }.padding(.bottom)
//                        .settingsBackground()
                    }.settingsBackground()
                }


//                .frame(width: geometry.size.width / 2,
//                       height: geometry.size.height / 5)
//                .background(Color.secondary.colorInvert())
//                .foregroundColor(Color.primary)
//                .cornerRadius(20)
//                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }

}
