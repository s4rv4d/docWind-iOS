//
//  DocumentPickerView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import PDFKit
import CoreData

struct DocumentPickerView: UIViewControllerRepresentable {
    
    // MARK: - View modifiers
    @State var headPath: String
    @State var headName: String
    @Binding var alertState: Bool
    @Binding var alertMessage: String
    @Environment(\.managedObjectContext) var context
    
    // MARK: - UIViewControllerRepresentable functions
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, headPath: headPath, headName: headName, context: context, alertState: $alertState, alertMessage: $alertMessage)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPickerView>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .open)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPickerView>) {}
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        // MARK: - Properties
        var parent: DocumentPickerView
        var headPath: String
        var headName: String
        var context: NSManagedObjectContext
        var alertState: Binding<Bool>
        var alertMessage: Binding<String>
        
        init(parent: DocumentPickerView, headPath: String, headName: String, context: NSManagedObjectContext, alertState: Binding<Bool>, alertMessage: Binding<String>) {
            self.parent = parent
            self.headPath = headPath
            self.headName = headName
            self.context = context
            self.alertState = alertState
            self.alertMessage = alertMessage
            
            print(headPath)
        }
        
        // MARK: - Delegate functions
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard urls.count > 0 else { return }
            // need to do this to access file
            guard let selectedFile = urls.first, selectedFile.startAccessingSecurityScopedResource() else { return }
            
            defer {
                DispatchQueue.main.async {
                    selectedFile.stopAccessingSecurityScopedResource()
                }
            }
            
            // first replace " " with "_" after removing percent encoding i.e., %20 for space
            var selectedFileName = selectedFile.absoluteString.removingPercentEncoding!.replacingOccurrences(of: " ", with: "_")
            selectedFileName = String(selectedFileName.split(separator: "/").last!)
            print(selectedFile)
            print(selectedFileName)
            
            if !selectedFileName.contains(".pdf") {
                selectedFileName += ".pdf"
            }
            
            
            processFile(fileUrl: selectedFile, fileName: selectedFileName)
        }
        
        // functions
        func processFile(fileUrl: URL, fileName: String) {
            // get PDFDocument instance from url
            guard let pdfDocument = PDFDocument(url: fileUrl) else { fatalError("could not open") }
            // get raw data from pdf to store
            guard let rawData = pdfDocument.dataRepresentation() else { return }
            // save to ubiquitous container first
            let finalName = fileName
            print("headPath: ",headPath)
//            let str = "\(String(headPath.split(separator: "/").last!).trimBothSides())"
            let finalCheck = DWFMAppSettings.shared.saveFileWithPDFContent(pdfData: rawData, pdfName: finalName, directoryRef: (headPath == "DocWind") ? nil : headPath)

            // checks
            if finalCheck.0 {
                let path = finalCheck.1

                if path != "" {
                    print("✅ SUCCESSFULLY SAVED FILE IN \(headPath)")
                    
                    self.addItem(itemName: finalName.replacingOccurrences(of: ".pdf", with: ""), itemType: DWPDFFILE, filePath: path)
                    
                } else {
                    // alert
                    self.alertMessage.wrappedValue = "File name already exists chose a new"
                    self.alertState.wrappedValue.toggle()
                }
            } else {
                // alert
                self.alertMessage.wrappedValue = "File name already exists chose a new"
                self.alertState.wrappedValue.toggle()
            }
            
        }
        
        func addItem(itemName: String, itemType: String, filePath: String) {
            //make a single object observation request
            let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
            fetchRequest.predicate = NSPredicate(format: "name == %@", headName)
            
            do {
                let content = try context.fetch(fetchRequest)

                if let docWindContent = content.first {
                                    
                    // add new item
                    let itemName = itemName
                    let iconName = "blue"
                    let itemType = itemType
                    let isLocked = false
                    
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
                    self.alertMessage.wrappedValue = "Error saving file :("
                    self.alertState.wrappedValue.toggle()
                   }
                    
                } else {
                    print("❌ ERROR CONVERTING TO MainDocViewModel")
                }
            } catch {
                print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
            }
        }
    }
}

