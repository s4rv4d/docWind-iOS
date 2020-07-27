//
//  SubcriptionPageView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SubcriptionPageView: View {
    
    // MARK: - View Modifiers
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image("docwind logo-1")
                            .resizable()
                            .frame(width: 100, height: 100)
                            
                        Text("doc")
                           .font(.largeTitle)
                           .fontWeight(.bold)
                        + Text("Wind")
                           .font(.largeTitle)
                           .fontWeight(.bold)
                           .foregroundColor(.blue)
                        
                        Image(systemName: "plus")
                            .foregroundColor(.yellow)
                        Spacer()
                    }
                }
                
            if AppSettings.shared.bougthNonConsumable {
                HStack{
                    Text("You are a docWind" )
                        .font(.title)
                        .fontWeight(.thin)
                        + Text("+")
                            .font(.title)
                            .foregroundColor(.yellow)
                    + Text(" user 🤩, you have access to:")
                        .font(.title)
                        .fontWeight(.thin)
                }.padding()
                    .multilineTextAlignment(.center)
            } else {
                HStack{
                    Text("The docWind" )
                        .font(.title)
                        .fontWeight(.thin)
                        + Text("+")
                            .font(.title)
                            .foregroundColor(.yellow)
                    + Text(" features include the following")
                        .font(.title)
                        .fontWeight(.thin)
                }.padding()
                    .multilineTextAlignment(.center)
            }
        
                HStack {
                    VStack(spacing: 15) {
                        VStack {
                            Text("OCR Text recognition 👁")
                            .font(.body)
                            .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("Get important info right after scanning a document")
                                .font(.body)
                                .fontWeight(.thin)
                                .multilineTextAlignment(.center)
                        }
                        VStack {
                            Text("Fill and Sign ✍️")
                            .font(.body)
                            .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("Be able to edit your documents with annotations and custom signature")
                                .font(.body)
                                .fontWeight(.thin)
                                .multilineTextAlignment(.center)
                        }
                        VStack {
                            Text("Remove watermark 👣")
                            .font(.body)
                            .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("Dont like the default watermark?, remove it with docWind+")
                                .font(.body)
                                .fontWeight(.thin)
                                .multilineTextAlignment(.center)
                        }


                    }.padding()
                }.padding()
                Spacer()
                
                VStack {
                    Text("Support an iOS developer 😄")
                    .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                VStack{
                    Text("and more in the future updates 🤓")
                    .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                
                if !AppSettings.shared.bougthNonConsumable {
                    DWButton(text: "Buy docWind +", background: .green, action: {
                        FeedbackManager.mediumFeedback()
                        
                        checkConnection { (status, statusCode) in
                            if statusCode == 404 {
                                self.alertMessage = "No internet connection detected :("
                                self.showAlert.toggle()
                            } else {
                                IAPService.shared.purchaseProduct(product: .nonConsumable)
                            }
                        }
                    }).padding()
                    Text("---Or---")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DWButton(text: "Restore purchase", background: .blue, action: {
                        FeedbackManager.mediumFeedback()
                        
                        checkConnection { (status, statusCode) in
                            if statusCode == 404 {
                                self.alertMessage = "No internet connection detected :("
                                self.showAlert.toggle()
                            } else {
                                IAPService.shared.restorePurchase()
                                self.alertMessage = "Restored purchase"
                                self.showAlert.toggle()
//                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }).padding()
                }
                        
            }
            
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(self.alertMessage), dismissButton: .default(Text("Dismiss")))
            }
        }
    }
}
