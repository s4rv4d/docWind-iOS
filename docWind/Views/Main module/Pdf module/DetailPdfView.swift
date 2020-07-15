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
    @State private var activeContext: PDFDetailActiveView = .shareSheet
    @State private var isShown = false
    @State private var showEditView = false
    @State private var options: DrawingTool = .highlighter
    @State private var canEdit = false
    @State private var color: Color = Color(hex: "#000000")
    @State private var lineWidth: CGFloat = 3.0
    
    // MARK: - @Environment buttons
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Properties
    var body: some View {
        ZStack {
//            VStack {
                if url != "" {
                    PDFCustomView(fileURL: URL(string: url)!, options: $options, canEdit: $canEdit, color: $color)
                }
//            }
            
//            if canEdit {
//            SlideOverCardView(color: $color, lineWidth: $lineWidth).isHidden(!canEdit, remove: !canEdit)
                
//            }
        }
        .sheet(isPresented: $isShown) {
//            ShareSheetView(activityItems: [URL(string: self.url)!])
            SlideOverCardView(color: self.$color, lineWidth: self.$lineWidth)
        }
        .onAppear {
            self.getUrl()
        }
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        .navigationBarItems(leading: Button("Edit") {
            self.canEdit.toggle()
            }, trailing: Button(action: sharePdf) {
            Image(systemName: "square.and.arrow.up").font(.body)
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .cancel({ self.presentationMode.wrappedValue.dismiss() }))
        }
    }

    // MARK: - Functions
    func getUrl() {
        let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: "\(master)", fileName: "\(item.wrappedItemName).pdf")
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
    
    func sharePdf() {
        self.activeContext = .shareSheet
        self.isShown.toggle()
    }
}
