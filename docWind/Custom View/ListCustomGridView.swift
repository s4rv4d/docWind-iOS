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
    }
    
    var body: some View {
        
        var itemPrev: [[Int]] = []
        _ = (0..<11).publisher
        .collect(3)
        .collect()
        .sink(receiveValue: { itemPrev = $0 })
        
        return ForEach(0..<itemPrev.count, id: \.self){ array in
            HStack {
                
                if itemPrev[array].count <= 2 {
                    ForEach(itemPrev[array], id: \.self) { _ in
                        VStack {
                            Image("folderIcon")
                            .aspectRatio(contentMode: .fit)
                            Text("17BCE2246")
                            .font(.caption)
                        }
                    }
                } else {
                     ForEach(itemPrev[array], id: \.self) { _ in
                        VStack {
                            Image("folderIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            Text("17BCE2246")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}
