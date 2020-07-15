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
    @State private var editIconName = "pencil"
    
    // MARK: - @Environment buttons
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Properties
    var body: some View {
        VStack {
            if url != "" {
                PDFCustomView(fileURL: URL(string: url)!, options: $options, canEdit: $canEdit, color: $color)
            }
            Spacer()
            HStack {
                Image(systemName: self.editIconName)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .padding()
                    .onTapGesture {
                        self.canEdit.toggle()
                }
                
                Spacer()
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .padding()
                    .onTapGesture {
                        self.toolsTapped()
                }
            }.background(Color(.secondarySystemBackground))
        }

        .sheet(isPresented: $isShown) {
            
            if self.activeContext == .shareSheet {
                ShareSheetView(activityItems: [URL(string: self.url)!])
            } else if self.activeContext == .toolBox {
                PDFToolBarView(color: self.$color, lineWidth: self.$lineWidth, options: self.$options)
            }
        }
        .onAppear {
            self.getUrl()
        }
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: sharePdf) {
            Image(systemName: "square.and.arrow.up").font(.system(size: 20))
        })
            .toast(isShowing: $canEdit, text: Text("Edit: " + ((self.canEdit == true) ? "Enabled" : "Disabled")))

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
    
    func toolsTapped() {
        self.activeContext = .toolBox
        self.isShown.toggle()
    }
}
