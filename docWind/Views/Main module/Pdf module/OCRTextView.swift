//
//  OCRTextView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/10/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import UIKit
import VisionKit
import Combine

struct OCRTextView: View {
    
    // MARK: - @State variables
    @State var recognizedText: String = ""
    @State var imageToScan: [UIImage]
    @State private var textStyle = UIFont.TextStyle.body
    @State private var offsetVal: CGFloat = 0.0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                           }) {
                               Image(systemName: "xmark")
                                   .imageScale(.large)
                                   .frame(width: 40, height: 40)
                                   .foregroundColor(.white)
                                   .background(Color.blue)
                                   .clipShape(Circle())
                    
                           }
                           .padding()
                    Spacer()
                    Text("Scanned Text")
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: {
                               self.textStyle = (self.textStyle == .body) ? .title1 : .body
                           }) {
                               Image(systemName: "textformat")
                                   .imageScale(.large)
                                   .frame(width: 40, height: 40)
                                   .foregroundColor(.white)
                                   .background(Color.blue)
                                   .clipShape(Circle())
                    
                           }
                           .padding()
                }
                TextView(text: $recognizedText, textStyle: $textStyle)
                .padding(.horizontal)
            }.keyboardSensible(self.$offsetVal)
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
            
        }.background(BlurView().background(Color.white.opacity(0.6)))
        .onAppear {
            let txtRecog = TextRecognizer(recognizedText: self.$recognizedText)
            let images = self.imageToScan.map { $0.cgImage! }
            txtRecog.recognizeText(from: images)
        }
    }
}

