//
//  AddDirecView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct AddDirecView: View {
    
    // MARK: - @State properties
    @State private var direcName = ""
    @State private var selectedIconName = "blueFolder"
    @State private var alertMessage = ""
    @State private var isLocked = false
    @State private var showAlert = false
    
    // MARK: - Objects
    @ObservedObject var model: MainDocListViewModel
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var iconNames = ["blueFolder", "redFolder", "pinkFolder", "greenFolder", "yellowFolder"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Directory name")) {
                    TextField("Enter a name", text: $direcName)
                }
                
                Section(header: Text("Choose a folder icon")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<iconNames.count) { index in
                                VStack {
                                    Image(self.iconNames[index])
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode: .fit)
                                        .padding([.horizontal, .vertical])
                                        
                                    .padding()
                                    if self.selectedIconName == self.iconNames[index] {
                                        Circle()
                                            .foregroundColor(.primary)
                                        .frame(width: 10, height: 10)
                                            .padding(.bottom)
                                    }
                                }.onTapGesture {
                                    self.selectedIconName = self.iconNames[index]
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Lock folder?")) {
                    Toggle(isOn: $isLocked) {
                        Text("Private")
                    }
                }
            }
        .navigationBarTitle(Text("Add a new directory"))
            .navigationBarItems(leading: Button("Cancel") {
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
        // validation
        if direcName != "" {
            // make a file in file manager
            if DWFMAppSettings.shared.createSubDirectory(direcName: direcName) {
                // make a coredata entry
                print("✅ SUCCESFULLY CREATED SUB DIRECTORY \(direcName)")
                self.model.addANewItem(itemName: direcName, iconName: selectedIconName, itemType: DWDIRECTORY, locked: isLocked)
                self.presentationMode.wrappedValue.dismiss()
                
            } else {
                self.alertMessage = "Error creating sub directory :("
                self.showAlert.toggle()
            }
            
        } else {
            // alert
            self.alertMessage = "Please make sure to fill all fields :)"
            self.showAlert.toggle()
        }
    }
}
