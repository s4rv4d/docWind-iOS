//
//  SnapCarouselView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SnapCarouselView: View {
    
    // MARK: - Properties
    var UIState: UIStateModel = UIStateModel()
    var items: [Carditem]
    var title: String
    
    init(images: [UIImage], title: String) {
        self.items = images.map{ Carditem(id: images.firstIndex(of: $0)!, name: "none", image: $0) }
        self.title = title
    }
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32
        let cardHeight: CGFloat = ((UIScreen.main.bounds.height)/100 * 60)
        
//        let items = [Carditem]()
        
        return Canvas {
            VStack {
                CustomHeaderView(title: title, action: saveTapped)
//                Divider()
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
//                                    Text("\(item.name)")
                                    Image(uiImage: item.image)
                                    .resizable()
                                        .aspectRatio(contentMode: .fill)

                            }
                            .foregroundColor(Color.red)
                            .background(Color.black)
                            .cornerRadius(8)
//                            .shadow(color: .secondary, radius: 4, x: 0, y: 4)
                            .transition(AnyTransition.slide)
                            .animation(.spring())
                            .environmentObject(self.UIState)
                        }
                }.environmentObject(self.UIState)
                    .padding()
                
                HStack {
                    Button(action: {}){
                        VStack {
                            Image(systemName: "square.and.arrow.up")
//                            .padding()
                            Text("Share")
                        }
                    .frame(width: 60, height: 60)
                        
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }.padding()
//                    Spacer()
                    Button(action: {}){
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }.frame(width: 60, height: 60)
//                        .frame(width: 100, height: 100)
                        
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.padding()
//                    Spacer()
                    Button(action: {}){
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }.frame(width: 60, height: 60)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.padding()
//                    Spacer()
                    Button(action: {}){
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }.frame(width: 60, height: 60)
                            
//                        .frame(width: 100, height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.secondarySystemBackground), lineWidth: 1))
                            .foregroundColor(.blue)
                            .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }.padding()
                }.padding([.leading, .top, .bottom, .trailing])
                Spacer()
            }
        }
    }
    
    // MARK: - Functions
    func saveTapped() {
        print("saving... ")
    }
}
