//
//  AddPdfMainView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/6/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import PDFKit
import CodeScanner
import CoreData

struct AddPdfMainView: View {
    
    // MARK: - @State properties
    @State private var pdfName = "docWind\(Date())"
    @State private var selectedIconName = "blue"
    @State private var alertMessage: LocalizedStringKey = ""
    @State private var showAlert = false
    @State private var showScanner = false
    @State private var showingActionSheet = false
    @State private var activeSheet: ActiveOdfMainViewSheet? = nil
    @State private var activeAlertSheet: ActiveAlertSheet = .notice
    @State private var removeWatermark = false
    @State private var offsetVal: CGFloat = 0.0
    @State var codeScannerDismiss: Bool = false
    
    @State var pagesCopy: [UIImage] = [UIImage]()
    @State var pages: [UIImage] = [UIImage]()
    
    // for compression
    @State private var compressionIndex = 3
    private let compressionTypes = ["0%", "25%", "50%", "75%", "100%"]
    private let compressionValues: [CGFloat] = [1, 0.75, 0.50, 0.25, 0]
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    
    // MARK: - Properties
    var iconColors: [Color] = [.blue, .red, .green, .yellow, .pink, .primary, .gray, .orange, .purple]
    var iconNameString: [Color: String] = [.blue:"blue", .red:"red", .green:"green", .yellow:"yellow", .pink:"pink", .primary : "black", .gray: "gray", .orange: "orange", .purple: "purple"]
    
    var body: some View {
        NavigationView {
            
            /// this is never gonna execute, the reason we do this is so that the pagesCopy value updates, when view updates, weird need to look for better solutions
            Group {
                if pagesCopy.count == Int.max {
                    Image(uiImage: pagesCopy.first!)
                }
            }
            
            // Main contents
            Form {
                Section(header: Text("File name")) {
                    TextField("Enter a name", text: $pdfName)
                }
                
                Section(header: Text("Choose a file icon")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<iconColors.count) { index in
                                VStack {
                                    SFSymbol.docFill
                                        .foregroundColor(self.iconColors[index])
                                        .font(.body)
                                        .padding(.bottom)
                                    if self.selectedIconName == self.iconNameString[self.iconColors[index]]! {
                                        withAnimation{
                                            Circle()
                                                .foregroundColor(.primary)
                                            .frame(width: 10, height: 10)
                                                .padding(.bottom)
                                        }
                                    }
                                    }.padding()
                                .onTapGesture {
                                    self.selectedIconName = self.iconNameString[self.iconColors[index]]!
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Add pages?"), footer: Text("Tap on image for more options").isHidden(pages.count == 0)) {
                    if pages.count == 0 {
                        Button(action: addPagesTapped) {
                            Text("Add Pages")
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0 ..< pages.count, id: \.self){ index in
                                    Image(uiImage: (self.pages[index]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(8)
                                    .padding()
                                        .onTapGesture {
                                            self.imageTapped()
                                    }
                                }
                                Button(action: {
                                    self.addPagesTapped()
                                }) {
                                    Text("Add more +")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 150, height: 200)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                                    .padding()
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Compression percentage"), footer: Text("Approximate file size: \(approximateFileSize()) \n high resolution images can increase file size.")) {
                    Picker(selection: $compressionIndex, label: Text("")) {
                        ForEach(0 ..< compressionTypes.count) {
                            Text(compressionTypes[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
                
            .navigationBarTitle(Text(self.pdfName))
            .navigationBarItems(leading: Button(action: deleteFile){
                Text("Delete")
                    .foregroundColor(.red)
                }, trailing: Button(action:  saveTapped){
                    Text("Save")
                        .foregroundColor(Color(tintColor))
            })
            
        }
        
        .alert(isPresented: $showAlert) {
            if self.activeAlertSheet == .notice {
               return Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .cancel())
            } else {
               return Alert(title: Text("Alert"), message: Text("Are you sure you want to delete this document?"), primaryButton: .destructive(Text("Delete"), action: { self.presentationMode.wrappedValue.dismiss() }), secondaryButton: .cancel())
            }
        }
        
        
        .fullScreenCover(item: $activeSheet, onDismiss: { self.activeSheet = nil }) { item in
            switch item {
            case .scannerView:
                ScannerView(uiImages: self.$pagesCopy, sheetState: $activeSheet)
            case .pdfView:
                SnapCarouselView(mainImages: self.pages, mI: self.$pages, title: self.pdfName)
            case .photoLibrary:
                ImagePickerView(pages: self.$pagesCopy, sheetState: $activeSheet)
            case .subView:
                SubcriptionPageView()
            case .imageEdit:
                EditImageview(mainImages: self.$pages, mICopy: self.$pagesCopy, mainImagesCopy: self.pagesCopy, currentImage: self.pagesCopy.first!, currentImageCopy: self.pagesCopy.first!, imageCount: self.pagesCopy.count)
            case .scanQR:
                CustomCodeScanner(handler: self.handleScan, dismiss: $codeScannerDismiss)
            }
        }
        
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Options"), message: Text("Choose an option"), buttons: [
                .default(Text("Scan a document"), action: scanTapped),
                .default(Text("Scan QR/Barcode code"), action: scanQRTapped),
                .default(Text("Choose an image"), action: addImagesTapped),
                .cancel()
            ])
        }
        
    }
    
    // MARK: - Functions
    private func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        switch result {
        case .success(let urlString):
            scannedData(string: urlString)
        case .failure(let errorEnum) :
            print(errorEnum.localizedDescription)
            codeScannerDismiss.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.activeAlertSheet = .notice
                self.alertMessage = "Scanned QR Code didn't contain a valid URL to download a PDF from"
                self.showAlert.toggle()
            }
        }
    }
    
    private func scannedData(string: String) {
        guard string.contains(".pdf") else {
            codeScannerDismiss.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.activeAlertSheet = .notice
                self.alertMessage = "Scanned QR Code didn't contain a valid URL to download a PDF from"
                self.showAlert.toggle()
            }
            return
        }
        guard let downloadURL = URL(string: string) else { fatalError("failed to initialize URL from string.") }
        let cgpdfURL = downloadURL as CFURL
        guard let pdfDocument = CGPDFDocument(cgpdfURL) else { fatalError("failed to initialize PDFDocument") }
        
        let pageCount = pdfDocument.numberOfPages
        
        for i in 0 ... pageCount {
            autoreleasepool {
                guard let page = pdfDocument.page(at: i) else { return }
                let pageRect = page.getBoxRect(.mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let image = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                    ctx.fill(pageRect)
                    ctx.cgContext.drawPDFPage(page)
                }
                
                pages.append(image.downSampleImage())
            }
        }
        // to dismiss scanner
        codeScannerDismiss.toggle()
    }
    
    private func approximateFileSize() -> String {
        if self.pages.count != 0 {
            var totalSize = 0
            for image in pages {
                let bytes = image.jpegData(compressionQuality: compressionValues[compressionIndex])!
                totalSize += bytes.count
            }
            let floatBytes = Float(totalSize) * 0.000001
            return String(format: "%.2f", floatBytes) + " MB"
        } else {
            return "0 MB"
        }
    }
    
    private func saveTapped() {
        FeedbackManager.mediumFeedback()
        
        if (self.pages.count == 0) {
            self.activeAlertSheet = .notice
            self.alertMessage = "Make sure you have scan at least one document"
            self.showAlert.toggle()
        } else {
            let mainPages = self.pages
            
            // convert to pdf
            let pdfDocument = PDFDocument()
            for page in mainPages {
                
                // compression part here
                guard let bytes = page.downSampleImage().jpegData(compressionQuality: compressionValues[compressionIndex]) else { fatalError("failed to convert image into Data")}
                guard let image = UIImage(data: bytes) else { fatalError("failed to get image from data") }
                
                let pdfPage = PDFPage(image: image)
                let index = mainPages.firstIndex(of: page)!
                
                // store in pdfDocument
                pdfDocument.insert(pdfPage!, at: index)
            }
            
            // get raw data of pdf
            let rawPDFData = pdfDocument.dataRepresentation()!
            let pdfName = self.pdfName
            var finalPdfName = pdfName
            
            if pdfName.contains(" ") {
                finalPdfName = pdfName.replacingOccurrences(of: " ", with: "_")
            }
            
            if !pdfName.contains(".pdf") {
                finalPdfName += ".pdf"
            }
            
            
            // store to FM
            let dwfa = DWFMAppSettings.shared.saveFileWithPDFContent(pdfData: rawPDFData, pdfName: finalPdfName, directoryRef: nil)
            if dwfa.0 {
                let path = dwfa.1
                if path != "" {
                    print("✅ SUCCESSFULLY SAVED FILE IN DocWind")
                    
                    // now need to make a coredata entry
                    self.addANewItem(itemName: self.pdfName, iconName: selectedIconName, itemType: DWPDFFILE, locked: false, filePath: path)
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.activeAlertSheet = .notice
                    self.alertMessage = "File name already exists chose a new"
                    self.showAlert.toggle()
                }
                
            } else {
                self.activeAlertSheet = .notice
                self.alertMessage = "File name already exists chose a new"
                self.showAlert.toggle()
            }
        }
    }
    
    private func addPagesTapped() {
        self.showingActionSheet.toggle()
    }
    
    private func scanQRTapped() {
        self.activeSheet = .scanQR
    }
    
    private func showSubView() {
        self.removeWatermark = false
        self.activeSheet = .subView
    }
    
    private func scanTapped() {
        self.activeSheet = .scannerView
    }
    
    private func addImagesTapped() {
        self.activeSheet = .photoLibrary
    }
    
    private func imageTapped() {
        self.activeSheet = .pdfView
    }
    
    private func deleteFile() {
        FeedbackManager.mediumFeedback()
        self.activeAlertSheet = .delete
        self.showAlert.toggle()
    }
    
    func addANewItem(itemName: String, iconName: String, itemType: String, locked:Bool, filePath: String) {
        let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
        fetchRequest.predicate = NSPredicate(format: "name == %@", "DocWind")
        
        do {
            let content = try context.fetch(fetchRequest)

            if let docWindContent = content.first {
                                
                // add new item
                let itemName = itemName
                let iconName = iconName
                let itemType = itemType
                let isLocked = locked
                
                let item = ItemModel(context: context)
                item.itemName = itemName
                item.itemType = itemType
                item.itemURL = filePath
                item.iconName = iconName
                item.locked = NSNumber(booleanLiteral: isLocked)
                item.itemCreated = Date()
                item.origin = docWindContent
                
                do {
                   try context.save()
                   print("✅ created and saved \(itemName) to coredata")
               } catch {
                   print("❌ FAILED TO UPDATE COREDATA")
               }
                
            } else {
                print("❌ ERROR CONVERTING TO MainDocViewModel")
            }
        } catch {
            print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
        }
    }
}

struct AddPdfMainView_Previews: PreviewProvider {
    static var previews: some View {
        AddPdfMainView()
            .preferredColorScheme(.dark)
            
    }
}
