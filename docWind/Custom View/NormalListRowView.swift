//
//  NormalListRowView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct NormalListRowView: View {
    
    let itemArray: [ItemModel]
    
    @Binding var activeSheet: ActiveContentViewSheet
    @Binding var isShown: Bool
    
    
    var body: some View {
        return ForEach(0..<itemArray.count, id: \.self){ index in
            NavigationLink(destination: DetailedDirecView(item: self.itemArray[index])) {
                HStack {
                    Image((self.itemArray[index].wrappedItemType == DWDIRECTORY) ? self.itemArray[index].wrappedIconName : "bluePdfFile")
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fill)
                        .padding()
                    
                    Text(self.itemArray[index].wrappedItemName)
                        .font(.body)
                    .padding()
//                    Spacer()
                }
            }.settingsBackground()
        }
    }
}
