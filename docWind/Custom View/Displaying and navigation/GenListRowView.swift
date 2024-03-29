//
//  GenListRowView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/21/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import CoreData
import PDFKit

struct GenListRowView: View {
    
    // MARK: - Properties
    @ObservedObject var itemArray: ItemModel
    let masterFolder: String
    var iconNameString: [String: Color] = ["blue":.blue, "red":.red, "green":.green, "yellow":.yellow, "pink":.pink, "black": .primary, "gray": .gray, "orange": .orange, "purple": .purple]
    
    @State private var url = ""
    @State private var uiImages = [UIImage]()
    @State private var showSheet = false
    @State private var activeSheet: ActiveSheetForDetails? = nil
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var isDisabled = false
    @State private var showAlert = false
    @State private var alertMessage: LocalizedStringKey = ""
    @State private var alertTitle: LocalizedStringKey = ""
    @State private var isFile = false
    @State private var selectedItem: ItemModel? = nil
    
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
                    
        NavigationLink(destination: {
            VStack {
                    if self.itemArray.wrappedItemType == DWPDFFILE {
                        DetailPdfView(item: self.itemArray, master: self.masterFolder)
                            .environment(\.managedObjectContext, context)
                    } else {
                        DetailedDirecView(dirName: self.itemArray.wrappedItemName, pathName: self.masterFolder, item: self.itemArray)
                            .environment(\.managedObjectContext, context)
                    }

                }
        }()) {
            HStack {
                Group {
                    self.itemArray.wrappedItemType == DWPDFFILE ? SFSymbol.docFill : SFSymbol.folderFill
                }
                .foregroundColor(self.iconNameString[self.itemArray.wrappedIconName])
                .font(.body)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(self.itemArray.wrappedItemName)
                        .font(.body)
                    HStack {
                        Text(DWDateFormatter.shared.getStringFromDate(date: self.itemArray.wrappedItemCreated))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        Spacer()
                        if self.itemArray.wrappedItemType == DWPDFFILE {
                            if URL(fileURLWithPath: itemArray.wrappedItemUrl).fileSize != nil {
                                Text(NSString(format: "%.2f", URL(fileURLWithPath: itemArray.wrappedItemUrl).fileSize!) as String + " MB")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                // TODO: - Need to migrate data model
                                Text(approximateFileSize())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .debugPrint(itemArray.wrappedItemUrl)
                                
                            }
                        }
                    }
                }
                .padding()
                
            }.contextMenu {
                if self.itemArray.wrappedItemType == DWPDFFILE {
                    Button(action: {
                        DispatchQueue.main.async {
                            self.selectedItem = self.itemArray
                            self.uiImages = self.getImages()
                            self.activeSheet = .editSheet(images: self.uiImages, url: self.url, item: self.itemArray)
                        }
                    }) {
                        HStack {
                            SFSymbol.pencil
                            Text("Rename")
                        }
                    }
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            self.selectedItem = self.itemArray
                            self.getUrl()
                        }
                    }) {
                        HStack {
                            SFSymbol.share
                            Text("Share")
                        }.foregroundColor(.yellow)
                    }
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            self.selectedItem = self.itemArray
                            self.uiImages = self.getImages()
                            self.activeSheet = .editSheet(images: self.uiImages, url: self.url, item: self.itemArray)
                        }
                    }) {
                        HStack {
                            SFSymbol.pencilCircle
                            Text("Edit")
                        }
                    }
                }
                
                Button(action: {
                    self.isFile = self.itemArray.wrappedItemType == DWPDFFILE ? true : false
                    self.selectedItem = self.itemArray
                    self.deleteObject()
                }) {
                    HStack {
                        SFSymbol.trash
                        Text("Delete")
                    }.foregroundColor(.red)
                }
            }
        }
            
        .alert(isPresented: $showAlert) {
        
        if alertContext == .notice {
            return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), primaryButton: .default(Text("Dismiss")), secondaryButton: .destructive(Text("Delete"), action: {
                self.deleteObject()
                
            }))
        } else {
            return Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Dismiss"), action: {
                    print("retry")
                }))
            }
        }
        
        .sheet(item: $activeSheet, onDismiss: { self.activeSheet = nil }) { state in
            switch state {
            case .shareSheet(let url):
                ShareSheetView(activityItems: [URL(fileURLWithPath: url)])
                    .onAppear {
                        print("/////")
                        print(self.url)
                        print("/////")

                    }
            case .editSheet(let images, let url, let item):
                    EditPdfMainView(pdfName: self.itemArray.wrappedItemName, selectedIconName: self.itemArray.wrappedIconName, mainPages: images, url: url, item: item).environment(\.managedObjectContext, self.context)
            case .compressView:
                LoadingScreenView(item: self.itemArray, uiImages: self.uiImages)
            }
        }
        
    }
    
    // MARK: - Functions
    private func approximateFileSize() -> String {
        let filePath = String(itemArray.wrappedItemUrl.split(separator: "/").reversed().first!)
        let folderPath = String(itemArray.wrappedItemUrl.split(separator: "/").reversed()[1])
        
        guard let final = DWFMAppSettings.shared.containerUrl?.appendingPathComponent(folderPath).appendingPathComponent(filePath) else { return "0 MB" }
        print(final)
        
        guard let fileSize = final.fileSize else { return "0 MB" }
        return String(NSString(format: "%.2f", fileSize) as String + " MB")
    }
    
    func getUrl() {
        if selectedItem != nil {
            print(masterFolder)
            print(selectedItem!.wrappedItemUrl)
            let str = "\(String(self.selectedItem!.wrappedItemUrl.split(separator: "/").reversed()[1]).trimBothSides())"
            var name = selectedItem!.wrappedItemName
            
            if name.contains(" ") {
                name = name.replacingOccurrences(of: " ", with: "_")
            }
            
            if !name.contains(".pdf") {
                name += ".pdf"
            }
            
            let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: (str == "DocWind") ? nil : str, fileName: name)
            if dwfe.0 {
                let path = dwfe.1
                if path != "" {
                    url = path
                    DispatchQueue.main.async {
                        if self.url != "" {
                            self.activeSheet = .shareSheet(url: self.url)
                        }
                    }
                } else {
                    //error
                    self.alertContext = .error
                    self.alertTitle = "Error"
                    self.alertMessage = "Could'nt find file :("
                    self.showAlert.toggle()
                }
            } else {
                //error
                self.alertContext = .error
                self.alertTitle = "Error"
                self.alertMessage = "Could'nt find file :("
                self.showAlert.toggle()
            }
        }
    }
    
    func deleteObject() {
        if isFile {
            // deleting file
            if selectedItem != nil {
                
                let ref = "\(selectedItem!.wrappedItemUrl.split(separator: "/").reversed()[1])".trimBothSides()
                var fileName = selectedItem!.wrappedItemName
                
                if fileName.contains(" ") {
                    fileName = fileName.replacingOccurrences(of: " ", with: "_")
                }
                
                if !fileName.contains(".pdf") {
                    fileName += ".pdf"
                }
                
                if DWFMAppSettings.shared.deleteSavedPdf(direcName: (ref == "DocWind") ? nil : ref, fileName: fileName) {
                    print("SUCCESSFULLY DELETED CONFIRM 2 ✅")
                    ItemModel.deleteObject(in: context, sub: self.selectedItem!)
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "Couldnt delete file"
                    self.showAlert.toggle()
                }
            }
        } else {
            // deleting directory
            print("deleting direc")
            if selectedItem != nil {
                
                var folderName = selectedItem!.wrappedItemName
                
                if folderName.contains(" ") {
                    folderName = folderName.replacingOccurrences(of: " ", with: "_")
                }
                
                guard folderName != "DocWind" else {
                    return
                }
                
                if DWFMAppSettings.shared.deleteSavedFolder(folderName: folderName) {
                    print("SUCCESSFULLY DELETED CONFIRM 2 ✅")
                    // delete from direcmodel
                    let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
                    fetchRequest.predicate = NSPredicate(format: "name == %@", selectedItem!.wrappedItemName)
                    
                    do {
                        let content = try context.fetch(fetchRequest)
                        print(content)
                        if let docWindDirec = content.first {
                            DirecModel.deleteObject(in: context, sub: docWindDirec)
                        }
                    } catch {
                      print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
                    }
                    
                    ItemModel.deleteObject(in: context, sub: self.selectedItem!)
                                        
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "Couldnt delete folder"
                    self.showAlert.toggle()
                }
            }
        }
    }
    
    func getImages() -> [UIImage]{
        var imgs = [UIImage]()
                
        if selectedItem != nil {
            
            let str = "\(String(self.selectedItem!.wrappedItemUrl.split(separator: "/").reversed()[1]).trimBothSides())"
            var name = selectedItem!.wrappedItemName
            
            if name.contains(" ") {
                name = name.replacingOccurrences(of: " ", with: "_")
            }
            
            if !name.contains(".pdf") {
                name += ".pdf"
            }
                        
            let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: (str == "DocWind") ? nil : str, fileName: name)
            if dwfe.0 {
                let path = dwfe.1
                if path != "" {
                    // go url of pdf
                    
                    // now to extract imgs from pdf
                    if let pdf = CGPDFDocument(URL(string: path)! as CFURL) {
                        let pageCount = pdf.numberOfPages
                        
                        for i in 0 ... pageCount {
                            autoreleasepool {
                                guard let page = pdf.page(at: i) else { return }
                                let pageRect = page.getBoxRect(.mediaBox)
                                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                                let img = renderer.image { ctx in
                                    UIColor.white.set()
                                    ctx.fill(pageRect)
                                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                                    ctx.cgContext.drawPDFPage(page)
                                }
                                imgs.append(img.downSampleImage())
                            }
                        }
                        
                        if pageCount == imgs.count {
                            DispatchQueue.main.async {
                                self.url = path
                                
                            }
                            return imgs
                        }
                        
                    } else {
                        self.alertContext = .error
                        self.alertTitle = "Error"
                        self.alertMessage = "Could'nt get images from pdf :("
                        self.showAlert.toggle()
                    }
                    
                } else {
                    //error
                    self.alertContext = .error
                    self.alertTitle = "Error"
                    self.alertMessage = "Could'nt find file :("
                    self.showAlert.toggle()
                }
            } else {
                //error
                self.alertContext = .error
                self.alertTitle = "Error"
                self.alertMessage = "Could'nt find file :("
                self.showAlert.toggle()
            }
        }
        return imgs
    }
}

