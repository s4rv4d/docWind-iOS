//
//  ContentView.swift
//  docWind
//
//  Created by Sarvad shetty on 6/30/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    //MARK: - @State variables
    @State private var isShown = false
    @State var searchBarText = ""
    @State private var showingActionSheet = false
    @State var activeSheet: ActiveContentViewSheet = .intro
    @State private var presentAlert = false
    @State private var toggleSearchIcon = false
    @State private var item: ItemModel? = nil
    @State var changed = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var showAlert = false
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: DirecModel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DirecModel.created, ascending: true)], predicate: NSPredicate(format: "name == %@", "DocWind")) var items: FetchedResults<DirecModel>
    
    // MARK: - Properties
    var body: some View {
        NavigationView {
                    VStack(alignment: .leading) {
                        //check if contents isnt empty
                        if items.first != nil {
                            // display contents of file
                            if (items.first!.fileArray.count == 0) {
                                 NewStarterView()
                                .padding()
                            } else {
                                List {
                                    
                                    Section(header: Text("DocWind >").font(.caption)) {
                                        
                                        ForEach(0..<self.items.first!.fileArray.count, id: \.self){ index in
                                            NormalListRowView(itemArray: self.items.first!.fileArray[index], masterFolder: "\(DWFMAppSettings.shared.fileURL())").environment(\.managedObjectContext, self.context)
                                        }.onDelete(perform: self.deleteRow(at:))
                                        
                                        
                                    }
                                    
                                }
                                .listStyle(GroupedListStyle())
                            }
                        } else {
                            NewStarterView()
                            .padding()
                        }
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            .padding()
                                .onTapGesture {
                                    FeedbackManager.mediumFeedback()
                                    self.settingsTapped()
                            }
                        }.background(Color(.secondarySystemBackground))
                            .edgesIgnoringSafeArea(.bottom)
                    }
                        
                    .navigationBarTitle(Text("docWind"))
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarItems(leading:
                        Button(action: toggleSearch) {
                        Text("")
                        }
                        ,trailing: Button(action: showOptions){
                            Text("Add")
                    })
                }
            
        // On appear code
        .onAppear {
            IAPService.shared.getProducts()
            self.check()
        }
            
        // sheet code
        .sheet(isPresented: $isShown) {
            if self.activeSheet == .intro {
                IntroView()
                .environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createdDirec {
                AddDirecView().environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                AddPdfMainView().environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .settingsTapped {
                SettingsView()
            }
        }
        
        // action sheet code
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Options"), message: Text("Choose an option"), buttons: [
                .default(Text("Scan a document"), action: scanDocumentTapped),
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
    private func check() {
        print(AppSettings.shared.firstLoginDone)
        if !AppSettings.shared.firstLoginDone {
            if Device.IS_IPAD || Device.IS_IPHONE{
                self.isShown.toggle()
            }
        }
    }
    
    private func showOptions() {
        FeedbackManager.mediumFeedback()
        self.showingActionSheet.toggle()
    }
    
    private func createDiectory() {
        //1. bring up sheet
        self.activeSheet = .createdDirec
        self.isShown.toggle()
        //2. enter detials
        //3. reload list
    }
    
    private func toggleSearch() {
//        withAnimation {
//            self.toggleSearchIcon.toggle()
//        }
//
    }
    
    private func scanDocumentTapped() {
        print("❇️ SCAN DOC TAPPED")
        //bring uo editing page
        self.activeSheet = .createPdf
        self.isShown.toggle()
        //add pages and saves
    }
    
    private func settingsTapped() {
        self.activeSheet = .settingsTapped
        self.isShown.toggle()
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        guard let indexToDelete = indexSet.first else { return }
        let item = self.items.first!.fileArray[indexToDelete]
        
        
        if item.itemType == DWDIRECTORY {
            if DWFMAppSettings.shared.deleteSavedFolder(dirname: "\(DWFMAppSettings.shared.fileURL())", fileName: item.wrappedItemName) {
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
            if DWFMAppSettings.shared.deleteSavedPdf(direcName: "\(DWFMAppSettings.shared.fileURL())", fileName: "\(item.wrappedItemName).pdf") {
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
