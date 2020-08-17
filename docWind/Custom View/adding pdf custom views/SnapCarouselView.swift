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
    @State private var alertShown = false
    @State private var alertMessage = ""
    
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
                
                HStack {
                    Button(action: deleteTapped){
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Delete")
                                Spacer()
                            }.padding()
                            .foregroundColor(.red)
                            
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle())
                }.padding([.top, .bottom, .leading, .trailing])
                Spacer()
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
    
    private func deleteTapped() {
        print("delete tapped")
        // get current photo using UIState and remove from all arrays
        let currentPhotoIndex = UIState.activeCard
        UIState.activeCard = 0
        self.mainImages.remove(at: currentPhotoIndex)
        self.imagesState.remove(at: currentPhotoIndex)
    }
    
    private func addFilters() {
        
    }
}
