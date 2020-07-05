//
//  DetailedDirecView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct DetailedDirecView: View {
    
    @State var item: ItemModel
    
    var body: some View {
        VStack {
            Text("Hi")
                .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        }
    }
}
