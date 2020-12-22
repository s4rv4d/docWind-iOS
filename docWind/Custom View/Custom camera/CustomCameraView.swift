//
//  CustomCameraView.swift
//  Photostat
//
//  Created by Sarvad shetty on 10/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CustomCameraView: View {
    
    // MARK: - @Binding variables
    @Binding var images: [UIImage]
//    @Binding var sheetState: DetailFileState?
    
    @State var newImages: [UIImage] = []
    
    // MARK: - @State variables
    @State var didTapCapture = false
    @State var image: UIImage?
    @State var presentSheet = false
    @State var filterIndex = 0
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State private var type: CameraType = .single
//    @State private var imagesCombined = [ImageToCombine]()
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    
    
    // MARK: - Life cycle
    var body: some View {
        
        let boundImage = Binding<UIImage?>(get: { self.image }, set: { newValue in
            self.image = newValue
            if self.image != nil {
                
                if type == .single {
                    self.newImages.append(newValue!)
                }
//                self.presentSheet.toggle()
            }
        })
        
        return ZStack(alignment: .bottom) {
            
            Color.white
            
            // main camera
            if type == .single {
                CustomCameraRepresentable(image: boundImage, didTapCapture: $didTapCapture, filterIndex: $filterIndex)
            }
            
            // back view header
            VStack {
                CustomBackView(backButtonAction: backTapped, saveButtonAction: saveTapped)
                Spacer()
            }
            
            if type == .card {
                VStack {
                    Text("Make sure to wait for the green rectangle to appear over the card before tapping on capture button")
                        .font(.subheadline)
                        .settingsBackground()
                        .padding(.top, 60)
                    
                    Spacer()
                }
            }
            
            
            VStack {
                
                HStack {
                    Text("Single")
                        .foregroundColor((type == .single) ? .blue : .primary)
                        .onTapGesture {
                            self.type = .single
                        }
                    Spacer()
                    Text("Batch")
                        .foregroundColor((type == .batch) ? .blue : .primary)
                        .onTapGesture {
                            self.type = .batch
                        }
                    Spacer()
                    Text("Card")
                        .foregroundColor((type == .card) ? .blue : .primary)
                        .onTapGesture {
                            self.type = .card
                        }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .padding(.top, 10)
                
                CaptureButtonView()
                    .padding(.bottom)
                    .onTapGesture {
                        print("tapped")
                        
                        if type == .single {
                            if self.newImages.count < 1 {
                                self.didTapCapture = true
                            } else {
                                // alert
                                self.alertTitle = "Notice"
                                self.alertMessage = "When `Single` mode is selected on only photo can be taken"
                                self.showAlert.toggle()
                            }
                        }
                        else if type == .card {
//                            if self.imagesCombined.count < 2 {
//                                self.didTapCapture = true
//                            } else {
//                                // alert
//                                self.alertTitle = "Notice"
//                                self.alertMessage = "You've already scanned two sides of the card, tap on done to edit"
//                                self.showAlert.toggle()
//                            }
                        } else {
                            self.didTapCapture = true
                        }
                }
            }
//            .background(Color.theme)
            
            // image stack
            if type == .single {
                if self.newImages.count > 0 {
                    HStack {
                        CustomImageStack(images: $newImages)
                            .frame(width: 80, height: 120)
                            .padding()
                        Spacer()
                    }.animation(.easeIn)
                }
            }
//            else if type == .card {
//                HStack {
//                    CustomImageStack2(images: self.$imagesCombined)
//                        .frame(width: 120, height: 80)
//                        .padding()
//                    Spacer()
//                }.animation(.easeIn)
//            } else {
//                if self.newImages.count > 0 {
//                    HStack {
//                        CustomImageStack(images: $newImages)
//                            .frame(width: 80, height: 120)
//                            .padding()
//                        Spacer()
//                    }.animation(.easeIn)
//                }
//            }
            
        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Dismiss")))
//        }
    }
    
    // MARK: - Functions
    func backTapped() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func saveTapped() {
        print("saving....")
        print("total no.of images... \(self.images.count)")
        
        if type == .single {
            if newImages.count != 0 {
                newImages.forEach({ image in
                    self.images.append(image)
                })
                
                self.presentationMode.wrappedValue.dismiss()
//                self.sheetState = .edit
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        } else if type == .card {
//            if self.imagesCombined.count < 2  && self.imagesCombined.count != 0{
////                self.showAlert.toggle()
//            } else if self.imagesCombined.count == 0 {
//                self.presentationMode.wrappedValue.dismiss()
//            } else {
//                // before saving combine
//                self.combine()
//            }
        } else {
            if newImages.count != 0 {
                newImages.forEach({ image in
                    self.images.append(image)
                })
                
                self.presentationMode.wrappedValue.dismiss()
//                self.sheetState = .edit
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        
        
    }
    
    func combine() {
//        let combined = [self.imagesCombined[0], self.imagesCombined[1]]
//        self.images.append(mergeVertically(images: combined)!.resizeImageUsingVImage(size: CGSize(width: 600, height: 900))!)
//
//        self.presentationMode.wrappedValue.dismiss()
//        self.sheetState = .edit
    }
    
//    func mergeVertically(images: [ImageToCombine]) -> UIImage? {
//        let maxWidth = images.reduce(0.0) { max($0, $1.size.width) }
//        let totalHeight = images.reduce(0.0) { $0 + $1.size.height }
//
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: totalHeight), false, 0.0)
//        defer {
//            UIGraphicsEndImageContext()
//        }
//
//        let _ = images.reduce(CGFloat(0.0)) {
//            $1.image.draw(in: CGRect(origin: CGPoint(x: 0.0, y: $0), size: $1.size))
//            return $0 + $1.size.height
//        }
//
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
}

enum CameraType {
    case single
    case batch
    case card
}
