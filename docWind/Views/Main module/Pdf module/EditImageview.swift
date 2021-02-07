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
    @State var currentImageCopy: UIImage
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
    @State private var mainStage = true
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
                        .onAppear(perform: addWatermark)
                        
                }
                .padding()
                Spacer()
                VStack {
                    // ---> 1 editing options (x and tick)
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
                    
                    // ---> 2 first stage
                    if mainStage {
                        HStack {
                            
                            Button(action: cropSelected) {
                                VStack {
                                    Image(systemName: "crop")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Crop")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: adjustTapped) {
                                VStack {
                                    Image(systemName: "slider.horizontal.3")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Adjust")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: filtersTapped) {
                                VStack {
                                    Image(systemName: "camera.filters")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Filters")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: watermarkTapped) {
                                VStack {
                                    Image(systemName: "doc.append")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Watermark")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding([.horizontal, .top])
                    }
                    // ---> 2
                    
                    // ---> 3 crop
                    if cropActive {
                        HStack {
                            Button(action: backTappedCrop) {
                                VStack {
                                    Image(systemName: "chevron.left")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Done")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: rotateLeftTapped) {
                                VStack {
                                    Image(systemName: "rotate.left")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Rotate left")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()

                            Button(action: rotateRightTapped) {
                                VStack {
                                    Image(systemName: "rotate.right")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Rotate right")
                                        .font(.caption)
                                }
                            }

                        }
                        .padding([.horizontal, .top])
                    }
                    // ---> 3 crop
                    
                    // ---> 4 adjust
                    if adjustActive {
                        HStack {
                            Button(action: adjustBackTap) {
                                VStack {
                                    Image(systemName: "chevron.left")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Done")
                                        .font(.caption)
                                }
                            }
                            
//                            Spacer()
                            
                            /// sliders here
                            
                            VStack(alignment: .leading) {
                                Text("Brightness")
                                    .font(.caption)
                                CustomSlider(value: $brigtnessValue, range: 0...1)
                                    .frame(height: 30)
                                
                                Text("Contrast")
                                    .font(.caption)
                                CustomSlider(value: $contrastValue, range: 0...1)
                                    .frame(height: 30)
                                
                                Text("Saturation")
                                    .font(.caption)
                                CustomSlider(value: $saturationValue, range: 0...1)
                                    .frame(height: 30)
                                
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                    }
                    // ---> 4 adjust
                    
                    // ---> 5 filters
                    if filtersActive {
                        HStack {
                            Button(action: filterBackTapped) {
                                VStack {
                                    Image(systemName: "chevron.left")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Done")
                                        .font(.caption)
                                }
                            }
                            .padding(.trailing)
                            
                            CarouselFilterView(image: currentImageCopy, filteredImage: $currentImage)
                            
                        }
                        .padding([.horizontal, .top])
                    }
                    // ---> 5 filters
                    
                    // ---> 6 watemark
                    if watermarkActive {
                        HStack {
                            
                            Spacer()
                            Button(action: watermarkBackTapped) {
                                VStack {
                                    Image(systemName: "chevron.left")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Done")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: clearWaterMark) {
                                VStack {
                                    Image(systemName: "x.circle")
                                        .padding()
                                        .background(Color.secondarySystemGroupedBackground
                                                        .cornerRadius(7)
                                                        .frame(width: 60, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        )
                                    Text("Clear")
                                        .font(.caption)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                    }
                    // ---> 6 watermark
                    
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
    
    /// crop
    private func cropSelected() {
        mainStage = false
        cropActive = true
        adjustActive = false
        filtersActive = false
        watermarkActive = false
    }
    
    private func backTappedCrop() {
        print("here")
        print(currentPositionBottomRight)
        /// check if any change in coordinates
        if currentPositionTopLeft != .zero || currentPositionTopRight != .zero || currentPositionBottomLeft != .zero || currentPositionBottomRight != .zero {
            
            /// if changes detected, crop image
//            let _topRight = CGPoint(x: currentPositionBottomRight.x, y: currentPositionTopLeft.y)
//            let _bottomLeft = CGPoint(x: currentPositionTopLeft.x, y: currentPositionBottomRight.y)
            let _width = currentPositionTopLeft.distance(point: currentPositionTopRight)
            let _height = currentPositionTopLeft.distance(point: currentPositionBottomLeft)
            let cropArea = CGRect(origin: currentPositionTopLeft, size: CGSize(width: _width, height: _height))
            /// need to crop image
            let cgImage = currentImage.cgImage!
            
            let viewSize = currentImage.size
            
            let imageViewScaleWidth = CGFloat(viewSize.width)
            let imageViewScaleHeight = CGFloat(viewSize.height)

            let scale = 1 / min(imageViewScaleWidth, imageViewScaleHeight)
            let scaleWidth = 1 / imageViewScaleWidth
            let scaleHeight = 1 / imageViewScaleHeight


            let newWidth = cropArea.height * scale
            let newHeight = cropArea.width * scale
            let newXCord = (currentPositionTopLeft.x * scale) + newHeight
            let newYCord = (currentPositionTopLeft.y * scale)


            let newCropArea = CGRect(origin: CGPoint(x: newXCord,
                                                     y: newYCord),
                                     size: CGSize(width: newHeight,
                                                  height: newWidth))
            
            guard let croppedSourceImage = cgImage.cropping(to: cropArea) else {
                return
            }
            
            currentImage = UIImage(cgImage: croppedSourceImage)
        }
        
        mainStage = true
        cropActive = false
        adjustActive = false
        filtersActive = false
        watermarkActive = false
    }
    
    private func rotateRightTapped() {
        currentImage = currentImage.rotate(radians: -.pi/2)!
    }
    
    private func rotateLeftTapped() {
        currentImage = currentImage.rotate(radians: .pi/2)!
    }
    
    private func nextTapped() {
        
        FeedbackManager.mediumFeedback()
        
        /// brightness, contrast and etc changes current image update
        var updatedImage = currentImage.withSaturationAdjustment(byVal: saturationValue)
        updatedImage = updatedImage.withContrastAdjustment(byVal: contrastValue)
        updatedImage = updatedImage.withBrightnessAdjustment(byVal: brigtnessValue)
        
        currentImage = updatedImage
        
        /// update the currentImage into array copy
        mainImagesCopy[currentIndex] = currentImage
        
        /// final
        if currentIndex != (imageCount - 1) {
            currentIndex += 1
            
            /// bring up next image
            currentImage = mainImagesCopy[currentIndex]
            
            if currentIndex == (imageCount - 1) {
                stateName = "checkmark.circle.fill"
            }
        } else {
            /// exit

            /// update image array with updated image
            mainImages = mainImagesCopy
            
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func backTapped() {
        FeedbackManager.mediumFeedback()
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func adjustTapped() {
        mainStage = false
        cropActive = false
        adjustActive = true
        filtersActive = false
        watermarkActive = false
    }
    
    private func adjustBackTap() {
        
        defer {
            mainStage = true
            cropActive = false
            adjustActive = false
            filtersActive = false
            watermarkActive = false
        }
        
        /// do something before
        print("do something")
        
    }
    
    private func filtersTapped() {
        mainStage = false
        cropActive = false
        adjustActive = false
        filtersActive = true
        watermarkActive = false
    }
    
    private func filterBackTapped() {
        defer {
            mainStage = true
            cropActive = false
            adjustActive = false
            filtersActive = false
            watermarkActive = false
        }
        
        /// do something before
        print("do something")
    }
    
    private func watermarkTapped() {
        mainStage = false
        cropActive = false
        adjustActive = false
        filtersActive = false
        watermarkActive = true
    }
    
    private func watermarkBackTapped() {
        mainStage = true
        cropActive = false
        adjustActive = false
        filtersActive = false
        watermarkActive = false
    }
    
    private func addWatermark() {
        let mediaItem = MediaItem(image: currentImage)
        
        /// text
        let testStr = "Scanned by DocWind"
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15) ]
        let attrStr = NSAttributedString(string: testStr, attributes: attributes)
        
        let secondElement = MediaElement(text: attrStr)
        secondElement.frame = CGRect(x: 10, y: mediaItem.size.height - 50, width: mediaItem.size.width, height: mediaItem.size.height)
        
        mediaItem.add(elements: [secondElement])
        
        let mediaProcessor = MediaProcessor()
        mediaProcessor.processElements(item: mediaItem) { [self] (result, error) in
            currentImage = result.image!
        }
    }
    
    private func clearWaterMark() {
        if AppSettings.shared.bougthNonConsumable {
            currentImage = mainImagesCopy[currentIndex]
        } else {
            // alert
        }
    }
    
    
    func getDimension(w:CGFloat,h:CGFloat) -> CGFloat{
        if h > w {
            return w
        } else {
            return h
        }
        
    }
}

struct EditImageview_Previews: PreviewProvider {
    static var previews: some View {
        EditImageview(mainImages: .constant([UIImage(named: "server")!]), mainImagesCopy: [UIImage(named: "server")!], currentImage: UIImage(named: "server")!, currentImageCopy: UIImage(named: "server")!)
            .preferredColorScheme(.dark)
            
    }
}
