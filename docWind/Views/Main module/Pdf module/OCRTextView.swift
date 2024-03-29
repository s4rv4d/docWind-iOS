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
    @State var matches: [ResultURL] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                           }) {
                        SFSymbol.multiplyCircleFill
                               .foregroundColor(Color(tintColor))
                               .font(.system(size: 30))
                           }
                           .padding()
                    Spacer()
                    Text("Scanned Text")
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: {
                               self.textStyle = (self.textStyle == .body) ? .title1 : .body
                           }) {
                        SFSymbol.textFormat
                           .imageScale(.large)
                           .frame(width: 40, height: 40)
                           .foregroundColor(Color(tintColor))
                    
                           }
                           .padding()
                }
                .padding([.leading, .top, .trailing])
                TextView(text: $recognizedText, textStyle: $textStyle)
                .padding(.horizontal)
            }
            
            // slide card view over here
            SlideCardView(position: .middle) {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Detected data:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding([.leading, .top])
                            Spacer()
                        }
                        
                        if self.matches.count == 0 {
                            Text("Could not detect any addresses :(, try again.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            .padding()
                        } else {
                            VStack {
                                ForEach(self.matches, id: \.text) { data in
                                    
                                    SettingsRowForOCR(imageName: "circle.fill", title: "\(data.text)", imageColor: Color(tintColor), result: data, action: {
                                        FeedbackManager.mediumFeedback()
                                        var str = ""
                                        
                                        switch data.resultType.resultType {
                                        case .link :
                                            if data.text.contains("@") {
                                                str += "mailto:"
                                            }
                                            str += data.text
                                            
                                        case .address:
                                            str += "mailto:"
                                            str += data.text
                                        case .phoneNumber :
                                            str += "tel://"
                                            
                                            let num = data.text.replacingOccurrences(of: " ", with: "")
                                            str += num
                                            print(str)
                                            
                                        default:
                                            break
                                        }
                                        
                                        guard let url = URL(string: str) else { return }
                                        UIApplication.shared.open(url)
                                        }).settingsBackground()
                                }
                            }
                        }
                        Spacer()
                        Rectangle()
                            .foregroundColor(Color(.systemGray6))
                    }
                }
            }
            .keyboardSensible(self.$offsetVal)
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
            
        }
        .background(BlurView().background(Color.white.opacity(0.6)))
        .onAppear {
            let txtRecog = TextRecognizer(recognizedText: self.$recognizedText)
            let images = self.imageToScan.map { $0.cgImage! }
            txtRecog.recognizeText(from: images)
        }
        .onChange(of: recognizedText) { (value) in
            if value != "Scanning" {
                self.detectedData(self.recognizedText)
            }
        }
    }
    
    // MARK: - Functions
    private func detectedData(_ text: String) {
        print("entered detectedData function !!! ---->")
        print(text)
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.allTypes.rawValue)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        print("matches are: \(matches)")
        for match in matches {
            guard let range = Range(match.range, in: text) else { continue }
            let url = text[range]
            print(url)
            let res = ResultURL(text: String(url), resultType: match)
            self.matches.append(res)
        }
    }
}

struct ResultURL {
    var text: String
    var resultType: NSTextCheckingResult
}

