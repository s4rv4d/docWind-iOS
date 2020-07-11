//
//  DetailPdfView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct DetailPdfView: View {
    
    // AMRK: - @State variables
    @State var item: ItemModel
    
    // MARK: - Objects
    @ObservedObject var model: MainDocListViewModel
    
    // MARK: - Properties
    var body: some View {
        VStack {
            PDFCustomView(URL(string: item.wrappedItemUrl)!)
        }
    }

}
