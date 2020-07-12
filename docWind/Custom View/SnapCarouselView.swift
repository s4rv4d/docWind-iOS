//
//  SnapCarouselView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SnapCarouselView: View {
    
    // MARK: - @State variables
    @State private var activeSheet: ActiveCarouselViewSheet = .shareView
    @State private var isShown = false
    // use this to update/save to pdf format
    
    // MARK: - @Binding variables
    @Binding var imagesState: [UIImage]
    @Binding var imageWithWaterMark: [UIImage]
    @Binding var mainImages: [UIImage]
    
    // MARK: - Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var UIState: UIStateModel = UIStateModel()
    var title: String
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32
        let cardHeight: CGFloat = ((UIScreen.main.bounds.height)/100 * 60)
                
        return Canvas {
            VStack {
                CustomHeaderView(title: title, action: saveTapped)
                
                Carousel(
                    numberOfItems: CGFloat(mainImages.count),
                    spacing: spacing,
                    widthOfHiddenCards: widthOfHiddenCards
                    ) {
                        ForEach(mainImages, id: \.self) { item in
                            Item(
                                _id: Int(self.mainImages.firstIndex(of: item)!),
                                spacing: spacing,
                                widthOfHiddenCard: widthOfHiddenCards,
                                cardHeight: cardHeight
                                ) {
                                    Image(uiImage: item)
                                    .resizable()
                                        .aspectRatio(contentMode: .fill)

                            }
                            .foregroundColor(Color.red)
                            .background(Color.black)
                            .cornerRadius(8)
                            .shadow(color: .secondary, radius: 3, x: 0, y: 4)
                            .transition(AnyTransition.slide)
                            .animation(.spring())
                            .environmentObject(self.UIState)
                        }
                }.environmentObject(self.UIState)
                    .padding()
                
                HStack() {
                    Button(action: fillTapped){
                        HStack {
                            Image(systemName: "pencil.and.outline")
                            Text("Fill")
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }.padding()
                        
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    Spacer()
                    Button(action: ocrTapped){
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                            Text("OCR")
                            Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            }.padding()
                            
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }.padding([.top, .bottom, .leading, .trailing])
                Spacer()
            }
        }

        .sheet(isPresented: $isShown) {
            if self.activeSheet == .fillView {
                DrawOnImageView(mainImages: self.$mainImages, imagesWithoutWater: self.$imagesState, imageWithWater: self.$imageWithWaterMark, pageId: self.UIState.activeCard, image: self.mainImages[self.UIState.activeCard])
            } else if self.activeSheet == .ocrView {
                OCRTextView(recognizedText: "Scanning", imageToScan: self.mainImages[self.UIState.activeCard])
            }
        }
    }
    
    // MARK: - Functions
    private func saveTapped() {
        print("saving... ")
        // check number of images
        // get vm and store in filemanager and make ref to coredata
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func fillTapped() {
        print("fill tapped")
        self.activeSheet = .fillView
        self.isShown.toggle()
    }
    
    private func deleteTapped() {
        print("delete tapped")
        // bring up an alert
        self.presentationMode.wrappedValue.dismiss()
        
    }
    
    private func ocrTapped() {
        print("ocr tapped")
        self.activeSheet = .ocrView
        self.isShown.toggle()
    }
}
