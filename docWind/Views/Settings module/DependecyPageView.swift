//
//  DependecyPageView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/15/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
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
                            Text("ConfettiSwiftUI")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Spacer()
                            SFSymbol.exclamationMarkCircle
                                .foregroundColor(Color(tintColor))
                                .onTapGesture {
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
                    .settingsBackground()
                    .onTapGesture {
                        counter += 1
                    }
                    // --> 1
                    
                    // --> 2
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("MetalPetal")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Spacer()
                            SFSymbol.exclamationMarkCircle
                                .foregroundColor(Color(tintColor))
                                .onTapGesture {
                                    SettingsHelper.openUrl(url: "https://github.com/MetalPetal/MetalPetal.git")
                                }

                        }
                        .padding([.bottom])
                        Text("by MetalPetal")
                        Text("https://github.com/MetalPetal/MetalPetal.git")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("MIT License")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                    }
                    .settingsBackground()
                    // --> 2
                    
                    // --> 3
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Throttler")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Spacer()
                            SFSymbol.exclamationMarkCircle
                                .foregroundColor(Color(tintColor))
                                .onTapGesture {
                                    SettingsHelper.openUrl(url: "https://github.com/boraseoksoon/Throttler.git")
                                }

                        }
                        .padding([.bottom])
                        Text("by Jang Seoksoon")
                        Text("https://github.com/boraseoksoon/Throttler.git")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("MIT License")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                        
                    }
                    .settingsBackground()
                    // --> 3
                    
                    Spacer()
                }
                .padding(.top)
                ConfettiCannon(counter: $counter)
            }
            
        .navigationBarTitle(Text("Dependencies used"))
        .navigationBarItems(trailing:
                                Button(action:{
                                    self.presentationMode.wrappedValue.dismiss()
                                }){
                                    SFSymbol.multiplyCircleFill
                                        .foregroundColor(Color(tintColor))
                                        .font(.system(size: 25))
                                }
                            )
        }
    }
}

struct DependecyPageView_Previews: PreviewProvider {
    static var previews: some View {
        DependecyPageView()
    }
}
