//
//  AddDocGeneView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/5/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData

struct AddDocGeneView: View {
    // MARK: - @State properties
    @State private var direcName = ""
    @State var path: String
    @State var headName: String
    @State private var selectedIconName = "blue"
    @State private var alertMessage = ""
    @State private var isLocked = false
    @State private var showAlert = false
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var iconColors: [Color] = [.blue, .red, .green, .yellow, .pink, .primary, .gray, .orange, .purple]
    var iconNameString: [Color: String] = [.blue:"blue", .red:"red", .green:"green", .yellow:"yellow", .pink:"pink", .primary : "black", .gray: "gray", .orange: "orange", .purple: "purple"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Directory name")) {
                    TextField("Enter a name", text: $direcName)
                }
                
                Section(header: Text("Choose a folder icon")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<iconColors.count) { index in
                                VStack {
                                    SFSymbol.folderFill
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
                
//                Section(header: Text("Lock folder?")) {
//                    Toggle(isOn: $isLocked) {
//                        Text("Private")
//                    }
//                }
            }
        .navigationBarTitle(Text("Add a new directory"))
            .navigationBarItems(leading: Button("Cancel") {
                FeedbackManager.mediumFeedback()
                self.presentationMode.wrappedValue.dismiss()
                }, trailing: Button(action:  saveTapped){
                    Text("Save")
            })
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), primaryButton: .cancel(), secondaryButton: .default(Text("Retry")))
        }
    }
    
    // MARK: - Functions
    private func saveTapped() {
        FeedbackManager.mediumFeedback()
        print(headName)
        let fullNameArr = headName.split{$0 == "/"}.map(String.init)
        print(fullNameArr)
        
        let index = fullNameArr.firstIndex(of: "DocWind")! + 1
        
        let newArray = fullNameArr[index...]
        print(direcName)
        print(newArray)
        
        let newArrayString = newArray.joined(separator: "/")
        print(newArrayString)
        print(path)
        
        
        
        
        /// validation
        if direcName != "" {
//            if path != direcName {
//                // make a file in file manager
//                print(headName)
//                print(path)
//
//                let dwas = DWFMAppSettings.shared.createSubSubDirectory(headName: URL(string: headName)!, newDirecName: direcName.replacingOccurrences(of: " ", with: "_"))
//
//                if dwas.0 {
//                    let path = dwas.1
//                    if path != "" {
//                        // make a coredata entry
//                        print("✅ SUCCESFULLY CREATED SUB DIRECTORY \(direcName)")
//                        self.addANewItem(itemName: direcName, iconName: selectedIconName, itemType: DWDIRECTORY, locked: isLocked, filePath: path)
//                        self.presentationMode.wrappedValue.dismiss()
//                    } else {
//                        self.alertMessage = "Error creating sub directory :("
//                        self.showAlert.toggle()
//                    }
//
//                } else {
//                    self.alertMessage = "Folder name already exists chose a new one"
//                    self.showAlert.toggle()
//                }
//            } else {
//                self.alertMessage = "Main directory and sub directory cant have same names :("
//                self.showAlert.toggle()
//            }

        } else {
            // alert
            self.alertMessage = "Please make sure to fill all fields :)"
            self.showAlert.toggle()
        }
    }
    
    func addANewItem(itemName: String, iconName: String, itemType: String, locked:Bool, filePath: String) {
            //make a single object observation request
            let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
            fetchRequest.predicate = NSPredicate(format: "name == %@", path)
            print(direcName)
            do {
                let content = try context.fetch(fetchRequest)

                if let genDocContent = content.first {
                                    
                    // add new item
                    let itemName = itemName
                    let iconName = iconName
                    let itemType = itemType
                    let isLocked = locked
                    
                    let item = ItemModel(context: context)
                    item.itemName = itemName
                    item.itemURL = filePath
                    item.itemType = itemType
                    item.iconName = iconName
                    item.locked = NSNumber(booleanLiteral: isLocked)
                    item.itemCreated = Date()
                    item.origin = genDocContent
                            
                    let newDirec = DirecModel(context: context)
                    newDirec.name = itemName
                    newDirec.created = Date()
                    
                    do {
                       try context.save()
                       print("✅ created and saved \(itemName) to coredata")
                   } catch {
                       print("❌ FAILED TO UPDATE COREDATA")
                   }
                    
                } else {
                    print("❌ ERROR CONVERTING TO GeneralDocViewModel")
                }
            } catch {
                print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
            }
        }

}

