//
//  SettingsRow.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SettingsRow: View {
    var imageName: String
    var title: String
    var imageColor: Color
    var action: (()->()) = {}
    

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
                Image(systemName: "chevron.right")
                .foregroundColor(.blue)
            }
            .padding(.vertical, 10)
            .foregroundColor(.primary)
        }
    }
}

struct SettingsRowWithToggleAuth: View {
    var imageName: String
    var title: String
    @Binding var isOn: Bool
    @State var color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: imageName)
                .font(.headline)
                .foregroundColor(color)
                .frame(minWidth: 25, alignment: .leading)
                .accessibility(hidden: true)
            Text(title)
                .kerning(0)
            Spacer()
            UIToggle(isOn: $isOn) { (auth) in
                if auth {
                    AppSettings.shared.phoneSec = true
                    if AppSettings.shared.update() { print("Updated to true")  }
                } else {
                    AppSettings.shared.phoneSec = false
                    if AppSettings.shared.update() { print("Update to false") }
                }
            }
        }
        .padding(.vertical, 10)
        .foregroundColor(.primary)
    }
}

struct SettingsRowWithToggleNotifications: View {
    var imageName: String
    var title: String
    @Binding var isOn: Bool
    @Binding var color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: imageName)
                .font(.headline)
                .foregroundColor(color)
                .frame(minWidth: 25, alignment: .leading)
                .accessibility(hidden: true)
            Text(title)
                .kerning(0)
            Spacer()
            UIToggle(isOn: $isOn) { (auth) in
                if auth {
                    AppSettings.shared.notification = true
                    if AppSettings.shared.update() { print("Updated to true")  }
                } else {
                    AppSettings.shared.notification = false
                    if AppSettings.shared.update() { print("Update to false") }
                }
            }
        }
        .padding(.vertical, 10)
        .foregroundColor(.primary)
    }
}
