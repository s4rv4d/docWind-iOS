//
//  AppIconView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct AppIconView: View {
    
    // MARK: - Properties
    let appIcons = ["blackBlue", "blackGreen", "blackRed", "blackYellow"]
    let appIconName = ["Black and Blue", "Black and Green", "Black and Red", "Black and Yellow"]
    
    var body: some View {
        VStack {
            HeaderView(buttonTitle: "Cancel", title: "App Icons")
            Divider()
            List {
                Section(footer: Text("More to come soon :)")) {
                    ForEach(appIcons.indices, id: \.self) { i in
                        HStack{
                            Image(self.appIcons[i])
                            .resizable()
                                .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(self.appIconName[i])
                                .foregroundColor(.primary)
                            Spacer()
                        }.onTapGesture {
                            FeedbackManager.mediumFeedback()
                            self.changeIcon(to: self.appIcons[i])
                        }
                    }
                }
            }.listStyle(GroupedListStyle())
        }
    }
    
    // MARK: - Functions
    func changeIcon(to iconName: String) {
      guard UIApplication.shared.supportsAlternateIcons else {
        return
      }
        
      UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
        if let error = error {
          print("App icon failed to change due to \(error.localizedDescription)")
        } else {
          print("App icon changed successfully")
        }
      })
    }
}
