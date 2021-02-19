//
//  SubcriptionPageView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/13/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import ConfettiSwiftUI

struct SubcriptionPageView: View {
    
    // MARK: - View Modifiers
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var startConfetti = false
    @State private var counter = 0
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    var body: some View {
        ScrollView(.vertical) {
            ZStack {
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
                               .foregroundColor(Color(tintColor))
                            
                            SFSymbol.plus
                                .foregroundColor(.yellow)
                            Spacer()
                            
                            Button(action:{
                                self.presentationMode.wrappedValue.dismiss()
                            }){
                                SFSymbol.multiplyCircleFill
                                    .foregroundColor(Color(tintColor))
                                    .font(.system(size: 25))
                            }
                            .padding(.trailing)

                        }
                    }
                    
                if AppSettings.shared.bougthNonConsumable {
                    HStack{
                        Text("You are a docWind" )
                            .font(.title)
                            .fontWeight(.regular)
                            + Text("+")
                                .font(.title)
                                .foregroundColor(.yellow)
                        + Text(" user 🤩, you have access to:")
                            .font(.title)
                            .fontWeight(.regular)
                    }
                        .padding()
                        .multilineTextAlignment(.center)
                        .onAppear {
                            self.counter += 1
                        }
                } else {
                    HStack{
                        Text("The docWind" )
                            .font(.title)
                            .fontWeight(.regular)
                            + Text("+")
                                .font(.title)
                                .foregroundColor(.yellow)
                        + Text(" features include the following")
                            .font(.title)
                            .fontWeight(.regular)
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
                                    .fontWeight(.regular)
                                    .multilineTextAlignment(.center)
                            }
                            VStack {
                                Text("Fill and Sign ✍️")
                                .font(.body)
                                .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                Text("Be able to edit your documents with annotations and custom signature")
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .multilineTextAlignment(.center)
                            }
                            VStack {
                                Text("Remove watermark 👣")
                                .font(.body)
                                .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                Text("Dont like the default watermark?, remove it with docWind+")
                                    .font(.body)
                                    .fontWeight(.regular)
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
                        ShinyButton(text: "Buy docWind +", background: .green, action: {
                            FeedbackManager.mediumFeedback()
                            
                            checkConnection { (status, statusCode) in
                                if statusCode == 404 {
                                    self.alertMessage = "No internet connection detected :("
                                    self.showAlert.toggle()
                                } else {
                                    IAPService.shared.purchaseProduct(product: .nonConsumable)
                                    self.counter += 1
                                }
                            }
                        }).padding()
                        Text("---Or---")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ShinyButton(text: "Restore purchase", background: .blue, action: {
                            FeedbackManager.mediumFeedback()
                            
                            checkConnection { (status, statusCode) in
                                if statusCode == 404 {
                                    self.alertMessage = "No internet connection detected :("
                                    self.showAlert.toggle()
                                } else {
                                    IAPService.shared.restorePurchase()
                                    self.alertMessage = "Restored purchase"
                                    self.showAlert.toggle()
                                }
                            }
                        }).padding()
                    }
                            
                }
                ConfettiCannon(counter: $counter, confettis: [.text("💵"), .text("💶"), .text("💷"), .text("💴")], confettiSize: 30)
            }

            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text(self.alertMessage), dismissButton: .default(Text("Dismiss"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
        }
    }
}

struct SubcriptionPageView_Previews: PreviewProvider {
    static var previews: some View {
        SubcriptionPageView()
            .preferredColorScheme(.dark)
            
    }
}
