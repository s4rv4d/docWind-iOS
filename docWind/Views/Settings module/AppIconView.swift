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
    @State var appIcons = ["blackBlue", "blackGreen", "blackRed"]
    @State var appIconName = ["Black and Blue", "Black and Green", "Black and Red"]
    @State var selected = UIApplication.shared.alternateIconName
    
    var body: some View {
        VStack {
            HeaderView(buttonTitle: "Cancel", title: "App Icons")
            Divider()
            List {
                Section(footer: Text("More to come soon :)")) {
                    ForEach(appIcons.indices, id: \.self) { i in
                        Button(action: {
                            self.selected = self.appIcons[i]
                            FeedbackManager.mediumFeedback()
                            self.changeIcon(to: self.appIcons[i])
                        }){
                            HStack {
                                Image(self.appIcons[i])
                                .resizable()
                                    .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: .secondary, radius: 2, x: 0, y: 0)
                                
                                Text(self.appIconName[i])
                                    .foregroundColor(.primary)
                                Spacer()
                                
                                if self.selected == self.appIcons[i] {
                                    Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                                }
                            }.contentShape(Rectangle())
                            
                        }.buttonStyle(PlainButtonStyle())
                    }
                    Button(action: {
                        self.selected = nil
                        UIApplication.shared.setAlternateIconName(nil) { (error) in
                            if let error = error {
                                print("App icon failed to change due to \(error.localizedDescription)")
                              } else {
                                print("App icon changed successfully")
                            }
                        }
                    }) {
                        HStack{
                            Text("Reset to default")
                            Spacer()
                            if self.selected == nil {
                                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                            }
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
