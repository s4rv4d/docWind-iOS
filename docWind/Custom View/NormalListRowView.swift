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
    let masterFolder: String
    var iconNameString: [String: Color] = ["blue":.blue, "re":.red, "green":.green, "yellow":.yellow, "pink":.pink]
    
    @Binding var activeSheet: ActiveContentViewSheet
    @Binding var isShown: Bool
    
    
    var body: some View {
        return ForEach(0..<itemArray.count, id: \.self){ index in
            NavigationLink(destination: DetailedDirecView(item: self.itemArray[index], masterFolder: self.masterFolder, model: GeneralDocListViewModel(name: self.itemArray[index].wrappedItemName))) {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(self.iconNameString[self.itemArray[index].iconName!])
                        .font(.body)
//                        .padding()
                    
                    Text(self.itemArray[index].wrappedItemName)
                        .font(.body)
                    .padding()
//                    Spacer()
                }
            }
//            .settingsBackground()
        }
    }
}
