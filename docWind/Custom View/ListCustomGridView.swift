//
//  ListCustomGridView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import Combine

// NEED TO UPDATE IT TO MAKE IT DYNAMIC
struct ListCustomGridView: View {
    
    let itemArray: [ItemModel]
    
    init(itemArray:[ItemModel]) {
        self.itemArray = itemArray
        print(itemArray)
    }
    
    var body: some View {
        
        var itemPrev: [[Int]] = []
        _ = (0..<itemArray.count).publisher
        .collect(3)
        .collect()
        .sink(receiveValue: { itemPrev = $0 })
        
        return ForEach(0..<itemPrev.count, id: \.self){ array in
            HStack {
                
                if itemPrev[array].count <= 2 {
                    ForEach(itemPrev[array], id: \.self) { index in
                        VStack {
                            Image((self.itemArray[index].wrappedItemType == DWDIRECTORY) ? self.itemArray[index].wrappedIconName : "bluePdfFile")
                            .aspectRatio(contentMode: .fit)
                            Text(self.itemArray[index].wrappedItemName)
                            .font(.caption)
                        }.padding()
                    }
                } else {
                     ForEach(itemPrev[array], id: \.self) { index in
                        VStack {
                            Image((self.itemArray[index].wrappedItemType == DWDIRECTORY) ? self.itemArray[index].wrappedIconName : "bluePdfFile")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            Text(self.itemArray[index].wrappedItemName)
                                .font(.caption)
                        }.padding()
                    }
                }
            }.onAppear {
                print(itemPrev)
                print(self.itemArray)
            }
        }
    }
}
