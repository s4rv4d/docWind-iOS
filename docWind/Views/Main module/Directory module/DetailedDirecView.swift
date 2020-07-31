//
//  DetailedDirecView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData

struct DetailedDirecView: View {
    
    // MARK: - @State variables
    @State var item: ItemModel
    @State private var isShown = false
    @State private var showingActionSheet = false
    @State var activeSheet: ActiveContentViewSheet = .intro
    @State private var presentAlert = false
    @State private var toggleSearchIcon = false
    @State var masterFolder: String
    @State var masterDirecName: String = ""
    // alert
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var showAlert = false
    
    // MARK: - Objects
    @FetchRequest var items: FetchedResults<DirecModel>
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    
    init(dirName: String, pathName: String, item: ItemModel) {
        self._masterDirecName = State(initialValue: dirName)
        self._masterFolder = State(initialValue: pathName)
        self._item = State(initialValue: item)
        
        self._items = FetchRequest(
            entity: DirecModel.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "name == %@", "\(dirName)"))
        //    animation: .default)
    }
    
    // MARK: - Properties
    var body: some View {
        VStack(alignment: .leading) {
            //check if contents isnt empty
            if items.first != nil {
                // display contents of file
                if (items.first?.fileArray.count == 0) {
                    Text("Looks empty here, scan a new document or create a new directory using the '+' button above.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                        .padding([.leading, .trailing, .top])
                } else {
                    List {
                        Section(header: Text("\(String(masterFolder.split(separator: "/").last!)) > \(item.wrappedItemName)").font(.caption)) {
                            ForEach(0..<(items.first!.fileArray.count), id: \.self){ index in
                                GenListRowView(itemArray: (self.items.first!.fileArray[index]), masterFolder: self.item.wrappedItemUrl, activeSheet: self.$activeSheet, isShown: self.$isShown).environment(\.managedObjectContext, self.context)
                            }.onDelete(perform: self.deleteRow(at:))
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
            } else {
                Text("Looks empty here, scan a new document using the '+' button above.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                    .padding([.leading, .trailing, .top])
            }
            
            Spacer()
                
        }
        // sheet code
        .sheet(isPresented: $isShown) {
            if self.activeSheet == .intro {

            } else if self.activeSheet == .createdDirec {
                AddDocGeneView(path: self.masterDirecName, headName: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                AddPdfFileGenView(headPath: self.item.wrappedItemUrl, headName: self.masterDirecName).environment(\.managedObjectContext, self.context)
            }
        }
            
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing:
            
            HStack{
                Button(action: showOptions){
                    Image(systemName: "plus")
                        .font(.system(size: 25))
                        }
            }
        )
        
        // action sheet code
       .actionSheet(isPresented: $showingActionSheet) {
           ActionSheet(title: Text("Options"), message: Text("Choose an option"), buttons: [
               .default(Text("Scan a document"), action: createFile),
               .default(Text("Create a new directory"), action: createDiectory),
               .cancel()
           ])
       }
        
        .alert(isPresented: $showAlert) {
             Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Dismiss"), action: {
                    print("retry")
                }))
        }
        
    }
    
    // MARK: - Functions
    private func showOptions() {
        self.showingActionSheet.toggle()
    }

    private func createDiectory() {
        //1. bring up sheet
        self.activeSheet = .createdDirec
        self.isShown.toggle()
        //2. enter detials
        //3. reload list
    }
    
    private func createFile() {
        self.activeSheet = .createPdf
        self.isShown.toggle()
    }
    
    private func toggleSearch() {
        withAnimation {
            self.toggleSearchIcon.toggle()
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        guard let indexToDelete = indexSet.first else { return }
        let item = self.items.first!.fileArray[indexToDelete]
        print(item.wrappedItemUrl)
        if item.itemType == DWDIRECTORY {
            if DWFMAppSettings.shared.deleteSavedFolder(dirname: self.item.wrappedItemUrl, fileName: item.wrappedItemName) {
                print("SUCCESSFULLY DELETED FROM iCloud container ✅")
                
                // delete from direcmodel
                let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
                fetchRequest.predicate = NSPredicate(format: "name == %@", item.wrappedItemName)
                
                do {
                    let content = try context.fetch(fetchRequest)
                    print(content)
                    if let docWindDirec = content.first {
                        DirecModel.deleteObject(in: context, sub: docWindDirec)
                    }
                } catch {
                  print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
                }
                
                ItemModel.deleteObject(in: context, sub: item)
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "Couldnt delete folder"
                self.showAlert.toggle()
            }
        } else {
            
            if DWFMAppSettings.shared.deleteSavedPdf(direcName: self.item.wrappedItemUrl, fileName: "\(item.wrappedItemName).pdf") {
                print("SUCCESSFULLY DELETED FROM iCloud container ✅")
                
                ItemModel.deleteObject(in: context, sub: item)
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "Couldnt delete file"
                self.showAlert.toggle()
            }

        }
    }
}
