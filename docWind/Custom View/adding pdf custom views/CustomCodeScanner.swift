//
//  CustomCodeScanner.swift
//  docWind
//
//  Created by Sarvad Shetty on 07/03/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CodeScanner

struct CustomCodeScanner: View {
    
    let handler: (Result<String, CodeScannerView.ScanError>) -> ()
    
    @Binding var dismiss: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    var body: some View {
        ZStack(alignment: .top) {
            
            CodeScannerView(codeTypes: [.qr], scanMode: .once, completion: handler)
                .padding()
                .onChange(of: dismiss) { (_) in
                    self.presentationMode.wrappedValue.dismiss()
                }
            
            HStack {
                Spacer()
                Button(action:{
                    FeedbackManager.mediumFeedback()
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    SFSymbol.multiplyCircleFill
                        .foregroundColor(Color(tintColor))
                        .font(.system(size: 25))
                        .padding()
                }
            }
        }
    }
}
