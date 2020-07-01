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
                .padding()
            }

            Text("A mobile document scanner synced up with all your iCloud devices to help you manage and keep track of your documents")
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .allowsTightening(true)
            .padding()
            
            InfoView(imageName: "doc.text.viewfinder", title: "Scan", subTitle: "Scan single or multipage documents easily")
            .padding()
            
            InfoView(imageName: "lock.slash", title: "Protect documents", subTitle: "Proctect documents with touchid or faceid")
                .padding()
            
            InfoView(imageName: "square.and.arrow.up", title: "Share documents", subTitle: "Share documents to email and cloud services")
                .padding()
            Spacer()
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
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
