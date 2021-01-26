//
//  NewStarterView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/10/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct NewStarterView: View {
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack(alignment: .leading) {
                Text("Ah, its empty here")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .padding([.top, .leading, .trailing])
                VStack {
                    Text("👆 on the ") +
                    Text("PLUS").fontWeight(.bold).foregroundColor(Color(tintColor))
                    + Text(" button below to get started 😄")
                }.padding()
            }.settingsBackground()
//            .background(Color.blue)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue))
//                .font(.subheadline)
        }
    }
}
