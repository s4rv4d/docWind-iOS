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
    @State private var color: String = ""
    @State private var appIcons = ["blackBlue", "blackGreen", "blackRed"]
    @State private var appIconName = ["Black and Blue", "Black and Green", "Black and Red"]
    @State private var selected = UIApplication.shared.alternateIconName
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    let colorColumns = [GridItem(.adaptive(minimum: 44))]
    let colors = ["Pink", "Purple", "Red", "Gold", "Orange", "Green", "Teal", "Light Blue", "Dark Blue", "Midnight", "Dark Gray", "Gray"]
    
    init() {
        self._color = State(wrappedValue: self.tintColor)
    }
    
    var body: some View {
        VStack {
            HeaderView(buttonTitle: "Cancel", title: "App UI")
            Divider()
            List {
                Section(header: Text("App Icons"), footer: Text("More to come soon :)")) {
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
                                    SFSymbol.checkmarkSealFill
                                        .foregroundColor(.green)
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
                            Text("Default icon")
                            Spacer()
                            if self.selected == nil {
                                SFSymbol.checkmarkSealFill
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                Section(header: Text("App Tint")) {
                    LazyVGrid(columns: colorColumns) {
                        ForEach(colors, id: \.self) { item in
                            ZStack {
                                Color(item)
                                    /// aspect ratio of 1 turns it into square
                                    .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(6)
                                if item == color {
                                    SFSymbol.checkmarkCircle
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                }
                            }
                            .onTapGesture {
                                self.color = item
                                self.tintColor = item
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityAddTraits(
                                item == color
                                    ? [.isButton, .isSelected]
                                    : .isButton
                            )
                            .accessibilityLabel(LocalizedStringKey(item))
                        }
                    }
                }
                .padding(.vertical)
            }
            .listStyle(InsetGroupedListStyle())
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
