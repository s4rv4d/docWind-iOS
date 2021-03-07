//
//  AddPdfFileGenView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/12/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import PDFKit
import CoreData

struct AddPdfFileGenView: View {
    
    // MARK: - @State properties
    @State private var pdfName = "docWind\(Date())"
    @State private var selectedIconName = "blue"
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showScanner = false
    @State private var showingActionSheet = false
    
    @State var mainPages: [UIImage] = [UIImage]()
    @State var pages: [UIImage] = [UIImage]()
    @State var pagesCopy: [UIImage] = [UIImage]()
        
    @State private var activeSheet: ActiveOdfMainViewSheet? = nil
    @State private var activeAlertSheet: ActiveAlertSheet = .notice
    @State var deleteDoc = false
    @State private var offsetVal: CGFloat = 0.0
    @State var headPath: String
    @State var headName: String
    
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
            
            // contents
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
                                ForEach(0 ..< self.pages.count, id: \.self){ index in
                                    Image(uiImage: self.pages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(8)
                                        
//                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white))
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
//            .keyboardSensible(self.$offsetVal)
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
               return Alert(title: Text("Notice"), message: Text(alertMessage), primaryButton: .cancel(), secondaryButton: .default(Text("Retry")))
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
                ImagePickerView(pages: self.$pagesCopy, sheetState: self.$activeSheet)
            case .subView:
                SubcriptionPageView()
            case .imageEdit:
                EditImageview(mainImages: self.$pages, mICopy: self.$pagesCopy, mainImagesCopy: self.pagesCopy, currentImage: self.pagesCopy.first!, currentImageCopy: self.pagesCopy.first!, imageCount: self.pagesCopy.count)
            case .scanQR:
                EmptyView()
            }
        }
        
        
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Options"), message: Text("Choose an option"), buttons: [
                .default(Text("Scan a document"), action: scanTapped),
                .default(Text("Choose an image"), action: addImagesTapped),
                .cancel()
            ])
        }

    }
    
    // MARK: - Functions
    private func approximateFileSize() -> String {
        if self.pages.count != 0 {
            var totalSize = 0
            
            for image in pages {
                let bytes = image.jpegData(compressionQuality: compressionValues[compressionIndex])!
                totalSize += bytes.count
            }
            let floatBytes = Float(totalSize) * 0.000001
            print(floatBytes)
            return String(format: "%.2f", floatBytes) + "MB"
        } else {
            return "0 MB"
        }
    }
    
    private func addPagesTapped() {
        self.showingActionSheet.toggle()
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
    
    private func showSubView() {
        self.activeSheet = .subView
    }
    
    private func saveTapped() {
        FeedbackManager.mediumFeedback()
        if (self.pages.count == 0) {
            self.activeAlertSheet = .notice
            self.alertMessage = "Make sure you have scan atleast one document"
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
            
            print(headPath)
            // store to FM
            let dwfe = DWFMAppSettings.shared.saveFileWithPDFContent(pdfData: rawPDFData, pdfName: finalPdfName, directoryRef: headPath)
            
            if dwfe.0 {
                let path = dwfe.1
                if path != "" {
                    print("✅ SUCCESSFULLY SAVED FILE IN \(headPath)")
                    
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
                self.alertMessage = "Could not save file"
                self.showAlert.toggle()
            }
        }
    }
    
    func addANewItem(itemName: String, iconName: String, itemType: String, locked:Bool, filePath: String) {
            //make a single object observation request
            let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
            fetchRequest.predicate = NSPredicate(format: "name == %@", headName)
            
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
