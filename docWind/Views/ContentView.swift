//
//  ContentView.swift
//  docWind
//
//  Created by Sarvad shetty on 6/30/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: - @State variables
    @State private var isShown = false
    
    // MARK: - Properties
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                self.check()
        }
        .sheet(isPresented: $isShown) {
            IntroView()
        }
    }
    
    // MARK: - Functions
    func check() {
        print(AppSettings.shared.firstLoginDone)
        if !AppSettings.shared.firstLoginDone {
            if Device.IS_IPAD || Device.IS_IPHONE{
                self.isShown.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
