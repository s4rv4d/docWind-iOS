//
//  SettingsView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/9/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    // MARK: - @State variables
    @State private var isToggled = AppSettings.shared.phoneSec
    @State private var showSheet = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var activeSheet: SettingActiveSheet = .docSub
    
    // MARK: - Properties
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                // ---- 1
                VStack {
                    SubHeadlineView(title: "Subscriptions")
                    VStack {
                        SettingsRow(imageName: "star.fill", title: "docWind Plus", imageColor: .yellow, action: dwPlusTapped)
                    }.settingsBackground()
                }
                // ---- 1
                
                // ---- 2
                VStack {
                    SubHeadlineView(title: "Options")
                    VStack {
                        SettingsRow(imageName: "app.badge", title: "Change app icon", imageColor: (AppSettings.shared.bougthNonConsumable) ? .green : .yellow, action: changeAppIcon)
                        Divider()
                        SettingsRowWithToggleAuth(imageName: "lock.shield", title: "Enable Lock", isOn: $isToggled, color: .red)
//                        Divider()
//                        SettingsRow(imageName: "exclamationmark.bubble", title: "Notification settings", imageColor: .blue, action: goToNotifications)
                    }.settingsBackground()
                }
                // ---- 2
                
                // ---- 3
                VStack {
                    SubHeadlineView(title: "Support")
                    VStack {
                        SettingsRow(imageName: "square.and.pencil", title: "Write a review", imageColor: .blue, action: writeAReviewTapped)
                        Divider()
                        SettingsRow(imageName: "wand.and.stars.inverse", title: "Feature request", imageColor: .pink, action: featureRequestTapped)
                        Divider()
                        SettingsRow(imageName: "ant", title: "Report a bug", imageColor: .red, action: reportABugTapped)
                    }.settingsBackground()
                }
                // ---- 3
                
                // ---- 4
                VStack {
                    SubHeadlineView(title: "Other")
                    VStack {
                        AppVersionRow(imageName: "info.circle", title: "App version", version: appVersion, color: .orange)
                        Divider()
                        SettingsRow(imageName: "square.and.arrow.up", title: "Share app?", imageColor: .blue, action: shareAppTapped)
                        Divider()
                        SettingsRow(imageName: "exclamationmark.circle", title: "About developer", imageColor: .purple, action: aboutDevTapped)
                    }.settingsBackground()
                }
                // ---- 4
            }
            .navigationBarTitle(Text("Settings"))
                
            .alert(isPresented: $showAlert) {
                Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Dismiss")))
            }
            .sheet(isPresented: $showSheet) {
                if self.activeSheet == .docSub {
                    SubcriptionPageView()
                } else if self.activeSheet == .appIcon {
                    AppIconView()
                } else if self.activeSheet == .mailBug {
                    MailView(isShowing: self.$showSheet, result: self.$result, subject: "Bug report", message: "Hi, I found a bug that i would like to report ")
                } else if self.activeSheet == .mailFeature {
                    MailView(isShowing: self.$showSheet, result: self.$result, subject: "Feature request", message: "Hi, I have an idea that i would like to suggest ")
                } else if self.activeSheet == .shareSheet {
                    ShareSheetView(activityItems: ["Not aware of how much you're spending on different subscriptions? try this \n\(SettingsHelper.appURL)"])
                }
            }
        }
    }
    
    // MARK: - Functions
    func dwPlusTapped() {
        print("present subscription page")
        self.activeSheet = .docSub
        self.showSheet.toggle()
    }
    
    func changeAppIcon() {
        
        if AppSettings.shared.bougthNonConsumable {
            print("change app icon tapped")
            self.activeSheet = .appIcon
            self.showSheet.toggle()
        } else {
            self.alertTitle = "Notice"
            self.alertMessage = "You need to be a docWind Plus user to access this feature"
            self.showAlert.toggle()
        }
    }
    
    func goToNotifications() {
        print("go to notifications page")
        //notification settings function
        DispatchQueue.main.async {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    UIApplication.shared.openURL(settingsUrl as URL)
                }
            }
        }
    }
    
    func writeAReviewTapped() {
        print("write a review tapped")
        SettingsHelper.writeReview()
    }
    
    func featureRequestTapped() {
        print("feature tapped")
        if MFMailComposeViewController.canSendMail() {
            self.showSheet.toggle()
            self.activeSheet = .mailFeature
        } else if let emailUrl = SettingsHelper.createEmailUrl(to: SettingsHelper.email, subject: "Feature request!", body: "Hi, I have an idea that i would like to suggest ") {
            UIApplication.shared.open(emailUrl)
        } else {
            self.alertTitle = "No Mail Accounts"
            self.alertMessage = "Please set up a Mail account in order to send email"
            self.showAlert.toggle()
        }
    }
    
    func reportABugTapped() {
        print("report a bug tapped")
        if MFMailComposeViewController.canSendMail() {
            self.showSheet.toggle()
            self.activeSheet = .mailBug
        } else if let emailUrl = SettingsHelper.createEmailUrl(to: SettingsHelper.email, subject: "Bug report!", body: "Hi, I found a bug that i would like to report ") {
            UIApplication.shared.open(emailUrl)
        } else {
            self.alertTitle = "No Mail Accounts"
            self.alertMessage = "Please set up a Mail account in order to send email"
            self.showAlert.toggle()
        }
    }
    
    func shareAppTapped() {
        print("share app tapped")
        self.showSheet.toggle()
        self.activeSheet = .shareSheet
    }
    
    func aboutDevTapped() {
        print("about dev tapped")
        SettingsHelper.openTwitter(twitterURLApp: SettingsHelper.personalTwitterApp, twitterURLWeb: SettingsHelper.personalTwitterWeb)
    }
}
