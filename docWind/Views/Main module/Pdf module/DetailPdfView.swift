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
    @State var master: String = ""
    @State var alertMessage = ""
    @State var showAlert = false
    
    // MARK: - @Environment buttons
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Properties
    var body: some View {
        VStack {
            if url != "" {
                PDFCustomView(URL(string: url)!)
            }
        }.onAppear {
            print("HERERERE")
            print("MASTER URL ",self.master)
            print("ITEM URL ",self.item.wrappedItemUrl)
            self.getUrl()
        }
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .cancel({ self.presentationMode.wrappedValue.dismiss() }))
        }
    }

    // MARK: - Functions
    func getUrl() {
        let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: nil, fileName: "\(item.wrappedItemName).pdf")
        if dwfe.0 {
            let path = dwfe.1
            if path != "" {
                url = path
            } else {
                //error
                self.alertMessage = "Could'nt load file :("
                self.showAlert.toggle()
            }
        } else {
            //error
            self.alertMessage = "Could'nt load file :("
            self.showAlert.toggle()
        }
    }
}
