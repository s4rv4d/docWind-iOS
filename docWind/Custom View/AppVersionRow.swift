//
//  AppVersionRow.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct AppVersionRow: View {
    var imageName: String
    var title: String
    var version: String
    @State var color: Color
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: imageName)
                .font(.headline)
                .foregroundColor(color)
                .frame(minWidth: 25, alignment: .leading)
                .accessibility(hidden: true)

            Text(title)
            Spacer()
            Text(version)
                .bold()
        }
        .accessibilityElement(children: .combine)
        .padding(.vertical, 10)
        .foregroundColor(.primary)
    }
}
