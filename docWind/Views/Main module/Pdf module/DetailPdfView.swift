//
//  DetailPdfView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import PDFKit

struct DetailPdfView: View, Equatable {
    
    // MARK: - @Environment buttons
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - @State variables
     var item: ItemModel
    @State var url: String = ""
     var master: String = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var activeAlertContext: ActiveAlertSheet = .error
    @State private var activeContext: PDFDetailActiveView = .toolBox
    @State private var isShown = false
    @State private var options: DrawingTool = .none
    @State private var canEdit = false
    @State private var canEditSignature = false
    @State private var color: Color = Color(hex: "#000000")
    @State private var lineWidth: CGFloat = 3.0
    @State var image: UIImage? = nil
    @State private var saveButton = false
    @State var saveTapped = false
    @State var alreadyAdded = false
    @State var images = [UIImage]()
    
    // MARK: - Properties
    var body: some View {
        VStack {
            if url != "" {
                PDFCustomView(fileURL: URL(string: url)!, options: options, canEdit: canEdit, canEditSignature: canEditSignature, color: color, saveTapped: saveTapped, image: image, alreadyAdded: $alreadyAdded)
                .debugPrint("PRESENTED PDFCUSTOMVIEW 📄")
            }
            Spacer()
            HStack {
                if canEdit {
                    Button("Save Edit") {
                        print("saving annotations")
                        self.canEdit = false
                        self.saveButton = true
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
                } else {
                    if !canEdit && !canEditSignature {
                        Image(systemName: "text.quote")
                            .font(.system(size: 20))
                            .foregroundColor( (AppSettings.shared.bougthNonConsumable) ? .blue : .yellow )
                            .padding()
                            .onTapGesture {
                                if !AppSettings.shared.bougthNonConsumable {
                                    self.alertTitle = "Notice"
                                    self.activeAlertContext = .noPurchase
                                    self.alertMessage = "You need to be docWind Plus user to access this feature"
                                    // dimiss without saving
                                    self.showAlert.toggle()
                                } else {
//                                    self.toolsTapped()
                                    self.extractText()

                                }
                        }
                    }
                }



                Spacer()
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20))
                    .foregroundColor( (AppSettings.shared.bougthNonConsumable) ? .blue : .yellow )
                    .padding()
                    .onTapGesture {
                        if !AppSettings.shared.bougthNonConsumable {
                            self.alertTitle = "Notice"
                            self.activeAlertContext = .noPurchase
                            self.alertMessage = "You need to be docWind Plus user to access this feature"
                            // dimiss without saving
                            self.showAlert.toggle()
                        } else {
                            self.toolsTapped()

                        }
                }
            }.debugPrint("HStack 💻")
            .background(Color(.black))
        }.debugPrint("VStack 🧸")

        .sheet(isPresented: $isShown) {
            if self.activeContext == .shareSheet {
                ShareSheetView(activityItems: [URL(string: self.url)!])
            } else if self.activeContext == .toolBox {
                PDFToolBarView(color: self.$color, lineWidth: self.$lineWidth, options: self.$options, openSignature: self.$isShown, activeContext: self.$activeContext, canEdit: self.$canEdit, canEditSignature: self.$canEditSignature, imageThere: self.$image)
            } else if self.activeContext == .signature {
                SignaturePageView(image: self.$image)
            } else if self.activeContext == .ocrPage {
                OCRTextView(recognizedText: "Scanning", imageToScan: self.images)
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
                return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel({
                    self.presentationMode.wrappedValue.dismiss()                    
                }))
            } else if activeAlertContext == .noPurchase {
                return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Cancel").foregroundColor(.blue)))
            } else {
                return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), primaryButton: .default(Text("Cancel").foregroundColor(.blue)), secondaryButton: .destructive(Text("Delete").foregroundColor(.red), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
        }
    }

    // MARK: - Functions
    func getUrl() {
        let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: "\(master)", fileName: "\(item.wrappedItemName.replacingOccurrences(of: " ", with: "_")).pdf")
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
    
    static func == (lhs: DetailPdfView, rhs: DetailPdfView) -> Bool {
        // << return yes on view properties which identifies that the
        // view is equal and should not be refreshed (ie. `body` is not rebuilt)
        return false
    }
    
    func extractText() {
        if let pdf = CGPDFDocument(URL(string: self.url)! as CFURL) {
            let pageCount = pdf.numberOfPages
            var imgs = [UIImage]()
            for i in 0 ... pageCount {
                guard let page = pdf.page(at: i) else { continue }
                let pageRect = page.getBoxRect(.mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let img = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)

                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                    ctx.cgContext.drawPDFPage(page)
                }
                imgs.append(img)
                print(imgs)
            }
            self.images = imgs
            self.activeContext = .ocrPage
            self.isShown.toggle()
        }
    }
}
