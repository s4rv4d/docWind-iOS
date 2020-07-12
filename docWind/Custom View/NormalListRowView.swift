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
    let itemArray: [ItemModel]
    let masterFolder: String
    var iconNameString: [String: Color] = ["blue":.blue, "red":.red, "green":.green, "yellow":.yellow, "pink":.pink]
    
    @Binding var activeSheet: ActiveContentViewSheet
    @Binding var isShown: Bool
    @State private var isDisabled = false
    @State private var showAlert = false
    
    var body: some View {
        
        return ForEach(0..<itemArray.count, id: \.self){ index in
            
            NavigationLink(destination: {
                VStack {
                        if self.itemArray[index].wrappedItemType == DWPDFFILE {
                            DetailPdfView(item: self.itemArray[index], master: self.masterFolder)
                                .debugPrint("MASTER \(self.masterFolder)")
                        } else {
                            DetailedDirecView(item: self.itemArray[index], masterFolder: self.masterFolder,
                            model: GeneralDocListViewModel(name: self.itemArray[index].wrappedItemName))
                        }

                    }
            }()) {
                HStack {
                    Image(systemName: (self.itemArray[index].wrappedItemType == DWPDFFILE) ? "doc.fill" : "folder.fill")
                        .foregroundColor(self.iconNameString[self.itemArray[index].iconName!])
                        .font(.body)
                    
                    VStack(alignment: .leading) {
                        Text(self.itemArray[index].wrappedItemName)
                            .font(.body)
                        Text(DWDateFormatter.shared.getStringFromDate(date: self.itemArray[index].wrappedItemCreated))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
//                    if self.itemArray[index].wrappedLocked {
//                        Spacer()
//                        Image(systemName: "lock.fill")
//                        .foregroundColor(self.iconNameString[self.itemArray[index].iconName!])
//                    }
                    
                }.contextMenu {
                    Button("Rename"){
                        print("renaming...")
                    }
                }
            }
                
        }
        
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("No bio metric detected"), dismissButton: .cancel(Text("Retry"), action: {
                        print("retry")
                    }))
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
}
