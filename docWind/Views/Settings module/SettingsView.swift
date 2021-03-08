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
    @State private var alertMessage: LocalizedStringKey = ""
    @State private var alertTitle: LocalizedStringKey = ""
    @State private var activeSheet: SettingActiveSheet? = nil
    
    // MARK: - Environment object
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    // MARK: - Properties
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let bundlerNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Subscriptions")) {
                    SettingsRow(imageName: "star.fill", title: "docWind Plus", imageColor: .yellow, action: dwPlusTapped)
                }
                
                Section(header: Text("Options")) {
                    if UIApplication.shared.supportsAlternateIcons {
                        SettingsRow(imageName: "gift.fill", title: "Change app icon", imageColor: (AppSettings.shared.bougthNonConsumable) ? .green : .yellow, action: changeAppIcon)
                    }
                    SettingsRow(imageName: "sparkle", title: "Update UI", imageColor: .pink, action: uiUpdateTapped)
                    SettingsRowWithToggleAuth(imageName: "lock.shield", title: "Enable Lock", isOn: $isToggled, color: .red)
                }
                
                Section(header: Text("Support")) {
                    SettingsRow(imageName: "square.and.pencil", title: "Write a review", imageColor: .blue, action: writeAReviewTapped)
                    SettingsRow(imageName: "wand.and.stars.inverse", title: "Feature request", imageColor: .pink, action: featureRequestTapped)
                    SettingsRow(imageName: "ant", title: "Report a bug", imageColor: .red, action: reportABugTapped)
                }
                
                Section(header: Text("Others")
                        , footer:
                            HStack {
                                Spacer()
                                Text("Made with ❤️ by Sarvad👨🏾‍💻")
                                .padding()
                                Spacer()
                            }
                ) {
                    AppVersionRow(imageName: "info.circle", title: "App version", version: appVersion + "(" + bundlerNumber + ")", color: .orange)
                    SettingsRow(imageName: "square.and.arrow.up", title: "Share app?", imageColor: .blue, action: shareAppTapped)
                    SettingsRow(imageName: "exclamationmark.circle", title: "About developer", imageColor: .purple, action: aboutDevTapped)
                    SettingsRow(imageName: "sparkles", title: "Dependencies used", imageColor: .green, action: dependencyTapped)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(leading: Button(action:{
                FeedbackManager.mediumFeedback()
                self.presentationMode.wrappedValue.dismiss()
            }){
                SFSymbol.multiplyCircleFill
                    .foregroundColor(Color(tintColor))
                    .font(.system(size: 25))
            })
                
            .alert(isPresented: $showAlert) {
                Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Dismiss")))
            }
            
            .fullScreenCover(item: $activeSheet, onDismiss: { self.activeSheet = nil }) { item in
                switch item {
                case .docSub:
                    SubcriptionPageView()
                case .appIcon:
                    AppIconView()
                case .mailBug:
                    MailView(isShowing: self.$showSheet, result: self.$result, subject: "Bug report", message: "Hi, I found a bug that i would like to report ")
                case .mailFeature:
                    MailView(isShowing: self.$showSheet, result: self.$result, subject: "Feature request", message: "Hi, I have an idea that i would like to suggest ")
                case .shareSheet:
                    ShareSheetView(activityItems: ["Try out docWind! \n\(SettingsHelper.appURL)"])
                case .dependency:
                    DependecyPageView()
                case .UIUpdate:
                    UpdateUIView()
                }
            }
        }
    }
    
    // MARK: - Functions
    func dwPlusTapped() {
        print("present subscription page")
        self.activeSheet = .docSub
    }
    
    func uiUpdateTapped() {
        print("present ui update view")
        self.activeSheet = .UIUpdate
    }

    func changeAppIcon() {
        
        if AppSettings.shared.bougthNonConsumable {
            print("change app icon tapped")
            self.activeSheet = .appIcon
        } else {
            self.alertTitle = "Notice"
            self.alertMessage = "You need to be docWind Plus user to access this feature"
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
        self.activeSheet = .shareSheet
    }
    
    func aboutDevTapped() {
        print("about dev tapped")
        SettingsHelper.openTwitter(twitterURLApp: SettingsHelper.personalTwitterApp, twitterURLWeb: SettingsHelper.personalTwitterWeb)
    }
    
    func dependencyTapped() {
        self.activeSheet = .dependency
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
            
    }
}
