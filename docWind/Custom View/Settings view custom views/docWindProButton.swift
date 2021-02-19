//
//  docWindProButton.swift
//  docWind
//
//  Created by Sarvad Shetty on 15/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct docWindProButton: View {
    var imageName: String
    var title: String
    var imageColor: Color
    var action: (()->()) = {}
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    

    var body: some View {
        Button(action: {
            self.action()
            FeedbackManager.mediumFeedback()
        }) {
            HStack(spacing: 8) {
                Image(systemName: imageName)
                    .font(.headline)
                    .foregroundColor(imageColor)
                    .frame(minWidth: 25, alignment: .leading)
                    .accessibility(hidden: true)
                Text(title)
                    .kerning(0)
                Spacer()
                SFSymbol.chevronRight
                .foregroundColor(Color(tintColor))
            }
            .padding(.vertical, 10)
            .foregroundColor(.primary)
        }
    }
}

struct docWindProButton_Previews: PreviewProvider {
    static var previews: some View {
        docWindProButton(imageName: "star.fill", title: "docWind Plus", imageColor: .yellow)
    }
}
