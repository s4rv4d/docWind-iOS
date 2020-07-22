//
//  NormalListRowView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct NormalListRowView: View {
    
    // MARK: - Properties
    let itemArray: ItemModel
    let masterFolder: String
    var iconNameString: [String: Color] = ["blue":.blue, "red":.red, "green":.green, "yellow":.yellow, "pink":.pink]
        
    @State private var isDisabled = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var isFile = false
    @State var selectedItem: ItemModel?
    @State private var selectedIndex: Int = 0
    
    @Environment(\.managedObjectContext) var context
    
    
    var body: some View {
        
        NavigationLink(destination: {
            VStack {
                    if self.itemArray.wrappedItemType == DWPDFFILE {
                        DetailPdfView(item: self.itemArray, master: self.masterFolder).debugPrint("ajdadahdsahaks")
                    } else {
                        DetailedDirecView(dirName: self.itemArray.wrappedItemName, pathName: self.masterFolder, item: self.itemArray).environment(\.managedObjectContext, self.context)
                    }

            }.debugPrint(self.masterFolder)
        }()) {
            HStack {
                Image(systemName: (self.itemArray.wrappedItemType == DWPDFFILE) ? "doc.fill" : "folder.fill")
                    .foregroundColor(self.iconNameString[self.itemArray.iconName!])
                    .font(.body)
                    
                
                VStack(alignment: .leading) {
                    Text(self.itemArray.wrappedItemName)
                        .font(.body)
                    Text(DWDateFormatter.shared.getStringFromDate(date: self.itemArray.wrappedItemCreated))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
            }.contextMenu {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Rename")
                    }
                }
                
                if self.itemArray.wrappedItemType == DWPDFFILE {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }.foregroundColor(.yellow)
                    }
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "pencil.circle")
                        Text("Edit")
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
    }
    
    // MARK: - Functions
    func authenticateView(status: @escaping(Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock app"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, authError) in
                DispatchQueue.main.async {
                    if success {
                        // allow access
                        status(true)
                    } else {
//                        self.authenticateView()
                        status(false)
                    }
                }
            }
        } else {
            //show error
            self.showAlert.toggle()
        }
    }
    
    func deleteObject() {
        if isFile {
            // deleting file
            if selectedItem != nil {
                if DWFMAppSettings.shared.deleteSavedPdf(direcName: self.masterFolder, fileName: "\(selectedItem!.wrappedItemName).pdf") {
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
                if DWFMAppSettings.shared.deleteSavedFolder(dirname: self.masterFolder, fileName: selectedItem!.wrappedItemName) {
                    print("SUCCESSFULLY DELETED CONFIRM 2 ✅")
                    ItemModel.deleteObject(in: context, sub: self.selectedItem!)
                } else {
                    self.alertTitle = "Error"
                    self.alertMessage = "Couldnt delete folder"
                    self.showAlert.toggle()
                }
            }
        }
    }
    
    func shareObject() {
        
    }
}
