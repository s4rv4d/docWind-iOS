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
    var title: LocalizedStringKey
    var imageColor: Color
    var action: (()->()) = {}
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    

    var body: some View {
        Button(action: {
            self.action()
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

struct SettingsRowForOCR: View {
    var imageName: String
    var title: String
    var imageColor: Color
    var result: ResultURL
    var action: (()->()) = {}
    
    @State private var imageName2 = "info.circle"
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"

    var body: some View {
        Button(action: {
            self.action()
            FeedbackManager.light()
        }) {
            HStack(spacing: 8) {
                Image(systemName: imageName)
//                    .font(.caption)
                    .resizable()
                    .foregroundColor(imageColor)
                    .frame(width: 5, height: 5)
                    .accessibility(hidden: true)
                Text(title)
                    .kerning(0)
                Spacer()
                Image(systemName: imageName2)
                .foregroundColor(Color(tintColor))
            }
            .padding(.vertical, 10)
            .foregroundColor(.primary)
        }
        .onAppear {
            switch self.result.resultType.resultType {
            case .link:
                self.imageName2 = "link"
            case .address:
                self.imageName2 = "link"
            case .phoneNumber:
                self.imageName2 = "phone"
            default:
                break
            }
        }
    }
}

struct SettingsRowWithToggleAuth: View {
    var imageName: String
    var title: LocalizedStringKey
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

