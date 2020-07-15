//
//  ToastView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/15/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct Toast<Presenting>: View where Presenting: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let text: Text

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                self.presenting()

                VStack {
                    Spacer()
                    self.text
                    .padding()
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(10)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                
                
                
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)

            }

        }

    }

}
