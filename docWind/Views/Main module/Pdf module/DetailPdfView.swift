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
    @State var url = ""
    // MARK: - Properties
    var body: some View {
        VStack {
            if url != "" {
                PDFCustomView(URL(string: url)!)
            }
        }.onAppear {
            print(self.item.wrappedItemUrl)
            self.getUrl()
        }
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
    }

    // MARK: - Functions
    func getUrl() {
        let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: "", fileName: "\(item.wrappedItemName).pdf")
        if dwfe.0 {
            let path = dwfe.1
            if path != "" {
                url = path
            } else {
                //error
            }
        } else {
            //error
        }
    }
}
