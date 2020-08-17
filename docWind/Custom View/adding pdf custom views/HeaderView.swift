//
//  HeaderView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/24/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    
    @Environment(\.presentationMode) var presentatioMode
    let buttonTitle: String
    let title: String
    let secondButton: String
    
    init(buttonTitle: String, title: String, secondButton: String = "Done") {
        self.buttonTitle = buttonTitle
        self.title = title
        self.secondButton = secondButton
    }
    
    var body: some View {
        HStack {
            Button(action: {
                FeedbackManager.mediumFeedback()
                self.presentatioMode.wrappedValue.dismiss() }) {
                Text(buttonTitle)
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(title)
            Spacer()
            Button(action: {
                FeedbackManager.mediumFeedback()
                self.presentatioMode.wrappedValue.dismiss() }) {
                Text(secondButton)
                    .foregroundColor(.blue)
            }
        }.padding([.leading, .top, .trailing])
    }
}
