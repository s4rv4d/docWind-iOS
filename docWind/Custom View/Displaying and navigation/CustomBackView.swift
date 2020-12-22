//
//  CustomBackView.swift
//  docWind
//
//  Created by Sarvad Shetty on 22/12/2020.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

import SwiftUI

struct CustomBackView: View {
    
    // MARK: - Attributes
    var backButtonAction: () -> Void
    var saveButtonAction: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.clear).frame(height: 60).shadow(color: Color(hex: "#000000").opacity(0.16), radius: 0.5, x: 0, y: 1)
            HStack(spacing: 15) {
                Button(action: backButtonAction) {
//                    Image("backButton")
//                        .padding(.leading, 20)
//                        .foregroundColor(.black)
//                        .padding()
                    #warning("change")
                    Text("Back")
                }
                Text("Take a snap")
                    .font(.title)
                Spacer()
                Button(action: saveButtonAction) {
                    Text("Done")
                        .padding([.leading, .trailing, .top, .bottom], 10)
                        .foregroundColor(.white)
                        .font(.body)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }.padding(.trailing)
            }.padding([.top])
        }
    }
}

struct CustomBackView_Previews: PreviewProvider {
    static var previews: some View {
        CustomBackView(backButtonAction: {}, saveButtonAction: {})
    }
}
