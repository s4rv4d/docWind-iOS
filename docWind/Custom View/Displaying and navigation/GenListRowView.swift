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

struct GenListRowView: View {
    
    // MARK: - Properties
    let itemArray: ItemModel
    let masterFolder: String
    var iconNameString: [String: Color] = ["blue":.blue, "red":.red, "green":.green, "yellow":.yellow, "pink":.pink, "black": .black, "gray": .gray, "orange": .orange, "purple": .purple]
    
    @State private var url = ""
    @State private var uiImages = [UIImage]()
    @State private var showSheet = false
    @State private var activeSheet: ActiveSheetForDetails = .shareSheet
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var isDisabled = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isFile = false
    @State private var selectedItem: ItemModel? = nil
    
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
                    
        NavigationLink(destination: {
            VStack {
                    if self.itemArray.wrappedItemType == DWPDFFILE {
                        DetailPdfView(item: self.itemArray, master: self.masterFolder)
                    } else {
                        DetailedDirecView(dirName: self.itemArray.wrappedItemName, pathName: self.masterFolder, item: self.itemArray)
                    }

                }
        }()) {
            HStack {
                Image(systemName: (self.itemArray.wrappedItemType == DWPDFFILE) ? "doc.fill" : "folder.fill")
                    .foregroundColor(self.iconNameString[self.itemArray.iconName!])
                    .font(.body)
                
                VStack(alignment: .leading) {
                    Text(self.itemArray.wrappedItemName)
                        .font(.body)
                    HStack {
                        Text(DWDateFormatter.shared.getStringFromDate(date: self.itemArray.wrappedItemCreated))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        Spacer()
                        if URL(string: self.itemArray.wrappedItemUrl)!.fileSize != nil {
                            Text(NSString(format: "%.2f", URL(string: self.itemArray.wrappedItemUrl)!.fileSize!) as String + " MB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                
            }.contextMenu {
                if self.itemArray.wrappedItemType == DWPDFFILE {
                    Button(action: {
                        self.selectedItem = self.itemArray
                        self.uiImages = self.getImages()
                        self.activeSheet = .editSheet
                        self.showSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Rename")
                        }
                    }
                    
                    Button(action: {
                        self.selectedItem = self.itemArray
                        self.getUrl()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }.foregroundColor(.yellow)
                    }
                    
                    Button(action: {
                        self.selectedItem = self.itemArray
                        self.uiImages = self.getImages()
                        self.activeSheet = .editSheet
                        self.showSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle")
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
                        Image(systemName: "trash")
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
        
        .sheet(isPresented: $showSheet) {
            if self.activeSheet == .shareSheet {
                ShareSheetView(activityItems: [URL(string: self.url)!])
            } else if self.activeSheet == .editSheet{
                // open editView
                if self.uiImages.count != 0 && self.url != "" {
                    EditPdfMainView(pdfName: self.itemArray.wrappedItemName, selectedIconName: self.itemArray.wrappedIconName, mainPages: self.uiImages, url: self.url, item: self.selectedItem!).environment(\.managedObjectContext, self.context)
                }
            }
        }
    }
    
    // MARK: - Functions
    func getUrl() {
        if selectedItem != nil {
            let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: "\(masterFolder)", fileName: selectedItem!.wrappedItemUrl)
            if dwfe.0 {
                let path = dwfe.1
                if path != "" {
                    url = path
                    self.activeSheet = .shareSheet
                    self.showSheet.toggle()
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
                if DWFMAppSettings.shared.deleteSavedPdf(direcName: self.masterFolder, fileName: selectedItem!.wrappedItemUrl) {
                    print("SUCCESSFULLY DELETED CONFIRM 2 ✅")
                    // now remove from coredata
                    ItemModel.deleteObject(in: context, sub: self.selectedItem!)
                } else {
                    // error
                    self.alertTitle = "Error"
                    self.alertMessage = "Couldnt delete file"
                    self.showAlert.toggle()
                }
            }
        } else {
            // deleting directory
            if DWFMAppSettings.shared.deleteSavedFolder(dirname: self.masterFolder, fileName: selectedItem!.wrappedItemUrl) {
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
    
    func getImages() -> [UIImage] {
        var imgs = [UIImage]()
        
        if selectedItem != nil {
            let dwfe = DWFMAppSettings.shared.showSavedPdf(direcName: "\(masterFolder)", fileName: selectedItem!.wrappedItemUrl)
            if dwfe.0 {
                let path = dwfe.1
                if path != "" {
                    // go url of pdf
                    url = path
                    
                    // now to extract imgs from pdf
                    if let pdf = CGPDFDocument(URL(string: url)! as CFURL) {
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
                                imgs.append(img)
                            }
                        }
                        
                        // now check if pageCount == imgs.count
                        if pageCount == imgs.count {
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

