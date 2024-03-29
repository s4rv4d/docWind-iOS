//
//  PDFToolBarView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/15/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct PDFToolBarView: View {
    
    // MARK: - @Binding variables
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    @Binding var options: DrawingTool
    @Binding var activeContext: PDFDetailActiveView?
    @Binding var canEdit: Bool
    @Binding var canEditSignature: Bool
    @Binding var imageThere: UIImage?
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    // MARK: - Properties
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                    HStack {
                            Spacer()
                            Button(action:{
                                self.presentationMode.wrappedValue.dismiss()
                            }){
                                SFSymbol.multiplyCircleFill
                                    .foregroundColor(Color(tintColor))
                                    .font(.system(size: 25))
                                    .padding()
                            }
                    }
                    HStack {
                        Text("Options")
                            .padding()
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Text("Change color")
                        ColorRow(selectedColor: $color)
                    }.settingsBackground()
                    
//                    // SAVING SIGNATURE
                    HStack {
                        Text("Signature")
                            .padding([.top, .leading, .trailing])
                        Spacer()
                    }
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.activeContext = .signature
                        self.canEditSignature.toggle()
                    }) {
                        HStack {
                            SFSymbol.signature
                            Text("Add signature")
                            Spacer()
                        }.padding()
                    }.settingsBackground()

                    // signature done
                    
                    HStack {
                        Text("Custom Annotations")
                            .padding([.top, .leading, .trailing])
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            FeedbackManager.light()
                            self.options = .eraser
                            self.canEdit = true
                            self.canEditSignature = false
                        }) {
                            VStack {
                                Image("eraser")
                                .resizable()
                                .frame(width: 100, height: 150)
                                    .opacity((options == .eraser) ? 1 : 0.5)
                            }
                        }
                        
                        Button(action: {
                            FeedbackManager.light()
                            self.options = .highlighter
                            self.canEdit = true
                            self.canEditSignature = false
                        }) {
                            VStack {
                                Image("highlighter")
                                .resizable()
                                .frame(height: 300)
                                .opacity((options == .highlighter) ? 1 : 0.5)
                            }
                        }
                        
                        Button(action: {
                            FeedbackManager.light()
                            self.options = .pen
                            self.canEdit = true
                            self.canEditSignature = false
                        }) {
                            VStack {
                                Image("pen")
                                .resizable()
                                .opacity((options == .pen) ? 1 : 0.5)
                            }
                        }
                        
                        Button(action: {
                            FeedbackManager.light()
                            self.options = .pencil
                            self.canEdit = true
                            self.canEditSignature = false
                        }) {
                            VStack {
                                Image("pencilPic")
                                .resizable()
                                .frame(width: 100)
                                .opacity((options == .pencil) ? 1 : 0.5)
                            }
                        }
                        Spacer()
                    }.frame(height: 200)
                    .buttonStyle(PlainButtonStyle())
                
                    Text("Use the \"Pen\" 🖋 for signatures")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                        .padding([.leading, .trailing, .top])
                    Spacer()
                }
        }
    }
}

