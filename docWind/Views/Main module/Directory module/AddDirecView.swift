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
    @State private var selectedIconName = "blue"
    @State private var alertMessage = ""
    @State private var isLocked = false
    @State private var showAlert = false
    
    // MARK: - Objects
    @ObservedObject var model: MainDocListViewModel
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var iconColors: [Color] = [.blue, .red, .green, .yellow, .pink]
    var iconNameString: [Color: String] = [.blue:"blue", .red:"red", .green:"green", .yellow:"yellow", .pink:"pink"]
    
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
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(self.iconColors[index])
                                        .font(.body)
//                                    Image(self.iconColors[index])
//                                        .frame(width: 100, height: 100)
//                                        .padding([.horizontal, .vertical])
//                                        Spacer()
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
