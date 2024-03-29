//
//  IntroView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/1/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct IntroView: View {
    
    // MARK: - Environment Variables
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Variables
    var body: some View {
            VStack(alignment: .center) {
                VStack {
                    TitleView()
                    .multilineTextAlignment(.center)
                    .padding([.top, .leading, .trailing])
                }

                Text("A mobile document scanner which helps you manage and keep track of your documents")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                    .padding([.leading, .trailing, .top])
                
                VStack {
                    InfoView(imageName: "doc.fill", title: "Scan", subTitle: "Scan all documents whether it's single page, multi page, or even ID cards.")
                        .padding([.top, .trailing, .leading])
                    
                    InfoView(imageName: "lock.fill", title: "Protect documents", subTitle: "Protect your sensitive documents using TouchID or FaceID.")
                        .padding([.top, .trailing, .leading])
                    
                    InfoView(imageName: "square.and.arrow.up.fill", title: "Share documents", subTitle: "Share your documents to iCloud or using email, directly from docWind.")
                        .padding([.top, .trailing, .leading])
                }.padding([.top, .leading, .trailing])
                Spacer()
                VStack(spacing: 10) {
                    Text("Let's get you started!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    
                    DWButton(text: "Continue", background: .blue) {
                        AppSettings.shared.firstLoginDone = true
                        if DWFMAppSettings.shared.creatingDirectory(direcName: "DocWind") {
                            if Device.IS_IPAD || Device.IS_IPHONE{
                                
                                //create a coredata for DocWind
                                let docWindDirec = DirecModel(context: self.context)
                                docWindDirec.name = "DocWind"
                                docWindDirec.created = Date()
                                
                                do {
                                    try self.context.save()
                                    print("✅ created and saved DocWind to coredata")
                                } catch {
                                    print("❌ FAILED TO UPDATE COREDATA")
                                }
                                
                                if AppSettings.shared.update() {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    print("❌ FAILED TO UPDATE APPSETTINGS")
                                }
                            }
                        } else {
                            print("❌ FAILED TO CREATED DIRECTORY")
                        }
                        
                    }.padding([.leading, .trailing, .bottom])
                }
            }
    }
}
