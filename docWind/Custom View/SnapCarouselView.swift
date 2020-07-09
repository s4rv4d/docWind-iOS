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
    @State var imagesState: [UIImage] = [UIImage]()
    
    // MARK: - Environment variables
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Properties
    var UIState: UIStateModel = UIStateModel()
    var items: [Carditem]
    var images: [UIImage]
    var title: String
    
    init(images: [UIImage], title: String) {
        self.items = images.map{ Carditem(id: images.firstIndex(of: $0)!, name: "none", image: $0) }
        self.images = images
        self.title = title
    }
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32
        let cardHeight: CGFloat = ((UIScreen.main.bounds.height)/100 * 60)
                
        return Canvas {
            VStack {
                CustomHeaderView(title: title, action: saveTapped)
                
                Carousel(
                    numberOfItems: CGFloat(items.count),
                    spacing: spacing,
                    widthOfHiddenCards: widthOfHiddenCards
                    ) {
                        ForEach(items, id: \.self) { item in
                            Item(
                                _id: Int(item.id),
                                spacing: spacing,
                                widthOfHiddenCard: widthOfHiddenCards,
                                cardHeight: cardHeight
                                ) {
                                    Image(uiImage: item.image)
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
                    Button(action: shareTapped){
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    .frame(width: 60, height: 60)
                        
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }.padding()
                    
                    Button(action: fillTapped){
                        VStack {
                            Image(systemName: "pencil.and.outline")
                            Text("Fill")
                        }.frame(width: 60, height: 60)
                        
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.padding()
//                    Spacer()
                    Button(action: ocrTapped){
                        VStack {
                            Image(systemName: "doc.text.viewfinder")
                            Text("OCR")
                        }.frame(width: 60, height: 60)
                            
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.padding()
                    
                    Button(action: deleteTapped){
                        VStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }.frame(width: 60, height: 60)
                            
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.red)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.padding()
                }.padding([.leading, .top, .bottom, .trailing])
                Spacer()
            }
        }
        .onAppear {
            self.imagesState = self.images
        }
        .sheet(isPresented: $isShown) {
            if self.activeSheet == .fillView {
                DrawOnImageView(images: self.$imagesState, pageId: self.UIState.activeCard)
            }
        }
    }
    
    // MARK: - Functions
    private func saveTapped() {
        print("saving... ")
    }
    
    private func fillTapped() {
        print("fill tapped")
        self.activeSheet = .fillView
        self.isShown.toggle()
    }
    
    private func deleteTapped() {
        print("delete tapped")
        
        // bring up an alert
    }
    
    private func shareTapped() {
        print("share tapped")
    }
    
    private func ocrTapped() {
        print("ocr tapped")
    }
}
