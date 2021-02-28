//
//  QGridCellView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/17/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData
import PDFKit

struct QGridCellView: View {
    
    @ObservedObject var item: ItemModel
    var iconNameString: [String: Color] = ["blue":.blue, "red":.red, "green":.green, "yellow":.yellow, "pink":.pink, "black": .primary, "gray": .gray, "orange": .orange, "purple": .purple]
    let masterFolder: String
    
    @State private var isDisabled = false
    @State private var url = ""
    @State private var uiImages = [UIImage]()
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var activeSheet: ActiveSheetForDetails? = nil
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var isFile = false
    @State var selectedItem: ItemModel?
    @State private var selectedIndex: Int = 0
    
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        NavigationLink(destination: {
            VStack {
                if self.item.wrappedItemType == DWPDFFILE {
                    DetailPdfView(item: self.item, master: self.masterFolder)
                } else {
                    DetailedDirecView(dirName: self.item.wrappedItemName, pathName: self.masterFolder, item: self.item).environment(\.managedObjectContext, self.context)
                }
            }
        }(), isActive: $isDisabled) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondarySystemGroupedBackground)
                    .frame(width: 146, height: 146)

                VStack {
                    HStack {
                        
                        Group {
                            self.item.wrappedItemType == DWPDFFILE ? SFSymbol.docFill : SFSymbol.folderFill
                        }
                        .font(.largeTitle)
                        .padding([.top, .leading])
                        .shadow(radius: 0.5)
                        .foregroundColor(self.iconNameString[self.item.wrappedIconName])
                        Spacer()

                        Group {
                            if self.item.wrappedItemType == DWDIRECTORY {
                                if self.item.wrappedLocked {
                                    SFSymbol.lockRectangleStackFill
                                        .foregroundColor(self.iconNameString[self.item.wrappedIconName])
                                        .padding(.trailing)
                                }
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(self.item.wrappedItemName)
                                .lineLimit(1)
                                .foregroundColor(.primary)

                            HStack {
                                
                                Text(DWDateFormatter.shared.getStringFromDate(date: self.item.wrappedItemCreated))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if self.item.wrappedItemType == DWPDFFILE {
                                    if URL(fileURLWithPath: item.wrappedItemUrl).fileSize != nil {
                                        Text(NSString(format: "%.2f", URL(fileURLWithPath: item.wrappedItemUrl).fileSize!) as String + " MB")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    } else {
                                        // TODO: - Need to migrate data model
                                        Text(approximateFileSize())
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .padding(.trailing, 5)
                                        
                                    }
                                }
                            }
                        }.padding([.bottom, .horizontal])
                        
                    }
                }.frame(width: 146, height: 146)
            }
            .onTapGesture(perform: checkForLock)
            .contextMenu {
            if self.item.wrappedItemType == DWPDFFILE {
                Button(action: {
                    DispatchQueue.main.async {
                        self.selectedItem = self.item
                        self.uiImages = self.getImagesAndPath()
                        self.activeSheet = .editSheet(images: self.uiImages, url: self.url, item: self.item)
                    }
                }) {
                    HStack {
                        SFSymbol.pencil
                        Text("Rename")
                    }
                }
                
                Button(action: {
                    DispatchQueue.main.async {
                        self.selectedItem = self.item
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
                        self.selectedItem = self.item
                        self.uiImages = self.getImagesAndPath()
                        self.activeSheet = .editSheet(images: self.uiImages, url: self.url, item: self.item)
                    }
                }) {
                    HStack {
                        SFSymbol.pencilCircle
                        Text("Edit")
                    }
                }
            }
            
            Button(action: {
                self.isFile = self.item.wrappedItemType == DWPDFFILE ? true : false
                self.selectedItem = self.item
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
                    EditPdfMainView(pdfName: self.item.wrappedItemName, selectedIconName: self.item.wrappedIconName, mainPages: images, url: url, item: item).environment(\.managedObjectContext, self.context)
            case .compressView:
                LoadingScreenView(item: self.item, uiImages: self.uiImages)
            }
        }
        
    }
    
    // MARK: - Functions
    func checkForLock() {
        print(self.item.wrappedLocked)
        
        if item.wrappedItemType == DWPDFFILE {
            isDisabled = true
        } else {
            if self.item.wrappedLocked {
                isDisabled = false
                
                authenticateViewGlobalHelper { (status, message) in
                    if status {
                        self.isDisabled = true

                    } else {
                        // bring up alert
                        self.alertContext = .error
                        self.alertTitle = "Error"
                        self.alertMessage = message
                        self.showAlert.toggle()
                    }
                }
            } else {
                isDisabled = true
            }
        }
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
    
    private func approximateFileSize() -> String {
        let folderPath = String(masterFolder.split(separator: "/").reversed().first!)
        let path = String(item.wrappedItemUrl.split(separator: "/").reversed().first!)
        
        var final: URL?
        
        if folderPath == "DocWind" {
            final = DWFMAppSettings.shared.containerUrl?.appendingPathComponent(path)
        } else {
            final = DWFMAppSettings.shared.containerUrl?.appendingPathComponent(folderPath).appendingPathComponent(path)
        }
        guard let f = final else { return "0 MB" }
        guard let fileSize = f.fileSize else { return "0 MB" }
        return String(NSString(format: "%.2f", fileSize) as String + " MB")
    }
    
    func getImagesAndPath() -> [UIImage] {
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
                    if let PDf = PDFDocument(url: URL(string: path)!) {
                        let pageCount = PDf.pageCount
                        
                        for i in 0 ... pageCount {
                            autoreleasepool {
                                guard let page = PDf.page(at: i) else { return }
                                let pageRect = page.bounds(for: .mediaBox)
                                print(page.annotations)
                                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                                let img = renderer.image { ctx in
                                    UIColor.white.set()
                                    ctx.fill(pageRect)
                                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                                    ctx.cgContext.drawPDFPage(page.pageRef!)
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
