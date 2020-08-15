//
//  DependecyPageView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/15/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import Shiny

struct DependecyPageView: View {
    
    // MARK: - Environment object
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
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
                            .foregroundColor(.blue)
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
                    
                }.onTapGesture {
                    FeedbackManager.mediumFeedback()
                    SettingsHelper.openUrl(url: "https://github.com/maustinstar/shiny")
                }
                .settingsBackground()
                // --> 1
                
                Spacer()
            }.padding(.top)
            
        .navigationBarTitle(Text("Dependecies used"))
        .navigationBarItems(leading: Button(action:{
            FeedbackManager.mediumFeedback()
            self.presentationMode.wrappedValue.dismiss()
        }){
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.blue)
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
