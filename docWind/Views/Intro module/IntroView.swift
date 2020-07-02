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
//        ScrollView(.vertical) {
            VStack(alignment: .center) {
                VStack {
                    TitleView()
                    .multilineTextAlignment(.center)
                    .padding()
                }

                Text("A mobile document scanner synced up with all your iCloud devices to help you manage and keep track of your documents")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
//                .allowsTightening(true)
                    .padding([.leading, .trailing, .top])
                
                InfoView(imageName: "doc.fill", title: "Scan", subTitle: "Scan all documents, whether they are single page, multi page, or even ID cards.")
                .padding()
                
                InfoView(imageName: "lock.fill", title: "Protect documents", subTitle: "Protect your sensitive documents using TouchID or FaceID.")
                    .padding()
                
                InfoView(imageName: "square.and.arrow.up.fill", title: "Share documents", subTitle: "Share your documents to iCloud or using email, directly from docWind.")
                    .padding()
                Spacer()
                VStack(spacing: 15) {
                    Text("Let's get you started!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    
                    DWButton(text: "Continue", background: .blue) {
                        AppSettings.shared.firstLoginDone = true
                        if Device.IS_IPAD || Device.IS_IPHONE{
                            if AppSettings.shared.update() {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }.padding([.leading, .trailing, .bottom])
                }
            }
//        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
