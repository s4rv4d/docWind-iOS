//
//  DependecyPageView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/15/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import Shiny
import ConfettiSwiftUI

struct DependecyPageView: View {
    
    // MARK: - Environment object
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    // MARK: - @State variables
    @State private var counter = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                     // --> 1
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Shiny")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .shiny()
                            Spacer()
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(Color(tintColor))
                                .onTapGesture {
                                    FeedbackManager.mediumFeedback()
                                    SettingsHelper.openUrl(url: "https://github.com/maustinstar/shiny")
                                }
                        }
                        .padding([.bottom])
                        Text("by Michal Vergas")
                        Text("https://github.com/maustinstar/shiny")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("MIT License")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                    }
                    .settingsBackground()
                    // --> 1
                    // --> 2
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("ConfettiSwiftUI")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(Color(tintColor))
                                .onTapGesture {
                                    print("hi")
                                    FeedbackManager.mediumFeedback()
                                    SettingsHelper.openUrl(url: "https://github.com/simibac/ConfettiSwiftUI")
                                }

                        }
                        .padding([.bottom])
                        Text("by Simon Bachmann")
                        Text("https://github.com/simibac/ConfettiSwiftUI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("MIT License")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                    }
                    .onTapGesture {
                        counter += 1
                    }
                    .settingsBackground()
                    // --> 2
                    
                    Spacer()
                }
                    .padding(.top)
                ConfettiCannon(counter: $counter)
            }
            
        .navigationBarTitle(Text("Dependecies used"))
        .navigationBarItems(leading: Button(action:{
            FeedbackManager.mediumFeedback()
            self.presentationMode.wrappedValue.dismiss()
        }){
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(Color(tintColor))
                .font(.system(size: 25))
        })
        }
    }
}

struct DependecyPageView_Previews: PreviewProvider {
    static var previews: some View {
        DependecyPageView()
    }
}
