//
//  CustomHeaderView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CustomHeaderView: View {
    
    // MARK: - @Environment variable
    @Environment(\.presentationMode) var presentationMode
    let headerTitle: String
    let saveAction: () -> Void
    
    // MARK: Init
    init(title: String, action: @escaping() -> Void) {
        self.headerTitle = title
        self.saveAction = action
    }
    
    // MARK: - Properties
    var body: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(headerTitle)
                .fontWeight(.medium)
            Spacer()
            Button(action: saveAction) {
                Text("Save")
                    .foregroundColor(.blue)
            }
        }.padding([.top, .horizontal])
//            .background(Color.secondary)
    }
}
