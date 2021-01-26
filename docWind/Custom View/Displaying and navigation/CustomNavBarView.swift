//
//  CustomNavBarView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/2/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CustomNavBarView: View {
    #warning("test this")
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    // MARK: - Private properties
    private let action: () -> Void
    private let buttonName: String
    private let buttonImage: String
    
    // MARK: - Init
    init(action: @escaping() -> Void, buttonName: String = "", buttonImage: String = "") {
        self.action = action
        self.buttonName = buttonName
        self.buttonImage = buttonImage
    }
    
    // MARK: - Properties
    var body: some View {
        HStack {
            Text("doc")
               .font(.largeTitle)
               .fontWeight(.bold)
            + Text("Wind")
               .font(.largeTitle)
               .fontWeight(.bold)
               .foregroundColor(Color(tintColor))
            Spacer()
            Button(action: action) {
                HStack {
                    Image(systemName: buttonImage)
                        .font(.title)
                    Text(buttonName)
                }
            }
        }
    }
}
