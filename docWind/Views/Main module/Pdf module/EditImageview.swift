//
//  EditImageview.swift
//  docWind
//
//  Created by Sarvad Shetty on 29/01/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct EditImageview: View {
    
    @Binding var mainImages: [UIImage]
    
    @State var mainImagesCopy: [UIImage]
    
    @State var currentImage: UIImage
    @State var currentIndex: Int = 0
    @State var imageCount: Int = 0
    
    // four points for image
    @State private var currentPositionTopLeft: CGPoint = .zero
    @State private var newPositionTopLeft: CGPoint = .zero

    @State private var currentPositionTopRight: CGPoint = .zero
    @State private var newPositionTopRight: CGPoint = .zero

    @State private var currentPositionBottomLeft: CGPoint = .zero
    @State private var newPositionBottomLeft: CGPoint = .zero

    @State private var currentPositionBottomRight: CGPoint = .zero
    @State private var newPositionBottomRight: CGPoint = .zero
    
    // edit action response
    @State private var cropActive = false
    @State private var adjustActive = false
    @State private var filtersActive = false
    @State private var watermarkActive = false
    @State private var finalStage = false
    
    // image properties
    @State var saturationValue: CGFloat = 1.0
    @State var contrastValue: CGFloat = 1.0
    @State var brigtnessValue: CGFloat = 0.0
    
    // states
    ///chevron.right.circle.fill
    ///checkmark.circle.fill
    @State private var stateName = "chevron.right.circle.fill"
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    // MARK: - Life cycle
    var body: some View {
        ZStack {
            Color.systemGroupedBackground
            VStack {
                VStack {
                    Image(uiImage: currentImage)
                        .resizable()
                        .saturation(Double(saturationValue))
                        .contrast(Double(contrastValue))
                        .brightness(Double(brigtnessValue * 0.2))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .overlay(
                            Group {
                                if cropActive {
                                    getCorners()
                                }
                            }
                        )
                        .padding()
                        
                }
                .padding()
                
                VStack {
                    // editing options
                    HStack {
                        Button(action: backTapped){
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(Color(tintColor))
                                .font(.system(size: 25))
                        }
                        
                        Spacer()
                        
                        Text("Edit Photo")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button(action: nextTapped) {
                            Image(systemName: stateName)
                                .foregroundColor(Color(tintColor))
                                .font(.system(size: 25))
                        }
                    }
                    .padding(.horizontal)
                    // ---> 1
                    
                    // ---> 2
                        HStack {
                            
                            Button(action: cropSelected) {
                                VStack {
                                    Image(systemName: "crop")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                        )
                                    Text("Crop")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                        )
                                    Text("Adjust")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "camera.filters")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                        )
                                    Text("Filters")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "doc.append")
                                        .resizable()
                                        .padding()
                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                        )
                                    Text("Watermark")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding([.horizontal, .top])
                    // ---> 2
                    
                }
                
                
                
            }
        }
        
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Functions
    private func getCorners() -> some View {

            return HStack {
                VStack {
                    ZStack {
                        CropImageViewRectangle(
                            currentPositionTopLeft: self.$currentPositionTopLeft,
                            currentPositionTopRight: self.$currentPositionTopRight,
                            currentPositionBottomLeft: self.$currentPositionBottomLeft,
                            currentPositionBottomRight: self.$currentPositionBottomRight
                        )

                        GeometryReader { geometry in
                            CropImageViewRectangleCorner(
                                currentPosition: self.$currentPositionTopLeft,
                                newPosition: self.$newPositionTopLeft,
                                displacementX: 0,
                                displacementY: 0
                            )

                            CropImageViewRectangleCorner(
                                currentPosition: self.$currentPositionTopRight,
                                newPosition: self.$newPositionTopRight,
                                displacementX: geometry.size.width,
                                displacementY: 0
                            )

                            CropImageViewRectangleCorner(
                                currentPosition: self.$currentPositionBottomLeft,
                                newPosition: self.$newPositionBottomLeft,
                                displacementX: 0,
                                displacementY: geometry.size.height
                            )

                            CropImageViewRectangleCorner(
                                currentPosition: self.$currentPositionBottomRight,
                                newPosition: self.$newPositionBottomRight,
                                displacementX: geometry.size.width,
                                displacementY: geometry.size.height
                            )
                        }
                    }

                    Spacer()
                }
                Spacer()
            }
        }
    
    private func cropSelected() {
        self.cropActive.toggle()
    }
    
    private func nextTapped() {
        
        FeedbackManager.mediumFeedback()
        
        /// update image array with updated image
        mainImages = mainImagesCopy
        
        /// final
        if currentIndex != (imageCount - 1) {
            currentIndex += 1
            
            if currentIndex == (imageCount - 1) {
                stateName = "checkmark.circle.fill"
            }
        } else {
            /// exit
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func backTapped() {
        FeedbackManager.mediumFeedback()
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct EditImageview_Previews: PreviewProvider {
    static var previews: some View {
        EditImageview(mainImages: .constant([]), mainImagesCopy: [], currentImage: UIImage(named: "server")!)
            .preferredColorScheme(.dark)
            
    }
}
