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
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    @State var activeAlertContext: ActiveAlertSheet = .error
    @State private var activeContext: PDFDetailActiveView = .signature
    @State private var isShown = false
    @State private var showEditView = false
    @State private var options: DrawingTool = .none
    @State private var canEdit = false
    @State private var canEditSignature = false
    @State private var delete = false
    @State private var color: Color = Color(hex: "#000000")
    @State private var lineWidth: CGFloat = 3.0
    @State private var editIconName = "pencil"
    @State var image: UIImage? = nil
    @State private var saveButton = false
    @State var saveTapped = false
    
    // MARK: - @Environment buttons
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Properties
    var body: some View {
        VStack {
            if url != "" {
                PDFCustomView(fileURL: URL(string: url)!, options: $options, canEdit: $canEdit, canEditSignature: $canEditSignature, color: $color, saveTapped: $saveTapped, image: image)
            }
            Spacer()
            HStack {
                if canEdit {
                    Button("Save Edit") {
                        print("saving annotations")
                        self.canEdit = false
                    }.settingsBackground()

                    Button("Save") {
                        print("saving annotation")
                        self.canEdit = false
                    }.settingsBackground()
                }
                
                if canEditSignature {
                    Button("Edit Sign") {
                        self.canEditSignature = true
                    }.settingsBackground()
                    
                    Button("Save") {
                        print("saving signature")
                        self.canEditSignature = false
                    }.settingsBackground()
                    
                }
                
                if saveButton {
                    if !canEdit && !canEditSignature {
                        Button("Save PDF") {
                            print("saving..")
                            
                            // save pdf
                            self.saveTapped.toggle()
                            self.saveButton.toggle()
//                            self.presentationMode
                            
                        }.settingsBackground()
                        
                        Button("Cancel") {
                            print("cancelling changes..")
                            // give an alert
                            self.alertTitle = "Notice"
                            self.activeAlertContext = .notice
                            self.alertMessage = "Are you sure you want to cancel the changes made"
                            // dimiss without saving
                            self.showAlert.toggle()
                            
                        }.settingsBackground()
                            .foregroundColor(.red)
                    }
                }
                
                
                
                Spacer()
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .padding()
                    .onTapGesture {
                        self.toolsTapped()
                        self.saveButton = true
                }
            }.background(Color(.black))
        }

        .sheet(isPresented: $isShown) {
            
            if self.activeContext == .shareSheet {
                ShareSheetView(activityItems: [URL(string: self.url)!])
            } else if self.activeContext == .toolBox {
                PDFToolBarView(color: self.$color, lineWidth: self.$lineWidth, options: self.$options, openSignature: self.$isShown, activeContext: self.$activeContext, canEdit: self.$canEdit, canEditSignature: self.$canEditSignature, imageThere: self.$image)
            } else if self.activeContext == .signature {
                SignaturePageView(image: self.$image)
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
            
            if activeAlertContext == .error {
                return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel({ self.presentationMode.wrappedValue.dismiss() }))
            } else {
                return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), primaryButton: .default(Text("Cancel").foregroundColor(.blue)), secondaryButton: .destructive(Text("Delete").foregroundColor(.red), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
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
                self.alertTitle = "Error"
                self.alertMessage = "Could'nt load file :("
                self.showAlert.toggle()
            }
        } else {
            //error
            self.alertTitle = "Error"
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
