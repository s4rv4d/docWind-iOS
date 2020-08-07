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
    @State private var tapped = false
    @State private var isShown = false
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
    
    // MARK: - ObservedObjects
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    init(dirName: String, pathName: String, item: ItemModel) {
        self._masterDirecName = State(initialValue: dirName)
        self._masterFolder = State(initialValue: pathName)
        self._item = State(initialValue: item)
        
        self._items = FetchRequest(
            entity: DirecModel.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "name == %@", "\(dirName)"), animation: .default)
    }
    
    // MARK: - Properties
    var body: some View {
        VStack {
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
                            Section(header: Text("\(String(masterFolder.split(separator: "/").last!)) > \(item.wrappedItemName)").font(.caption), footer: Text("Tap and hold on cell for more options").font(.caption)) {
                                ForEach(items.first!.fileArray.filter {
                                    searchBar.text.isEmpty ||
                                        $0.wrappedItemName.localizedStandardContains(searchBar.text)
                                }, id: \.self){ item in
                                    GenListRowView(itemArray: item, masterFolder: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
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
            
            // button
            ZStack(alignment: .bottom) {
                Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: showOptions) {
                    Image(systemName: "plus")
                        .rotationEffect(.degrees(tapped ? 45 : 0))
                        .foregroundColor(.white)
                        .font(.title)
                        .animation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0))
                    }
                    .padding(24)
                    .background(Color.blue)
                    .mask(Circle())
                    .animation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0))
                    .zIndex(10)                    .padding()
                // secondary buttons
                SecondaryButtonView(tapped: $tapped, icon: "folder.fill", color: .green, offsetX: 90, action: createDiectory).padding()
                SecondaryButtonView(tapped: $tapped, icon: "camera.fill", color: .pink, offsetY: -90, delay: 0.2, action: createFile).padding()
                SecondaryButtonView(tapped: $tapped, icon: "arrow.up.doc.fill", color: .orange, offsetX: -90, delay: 0.4, action: importTapped).padding()
            }
        }
        // sheet code
        .sheet(isPresented: $isShown) {
            if self.activeSheet == .intro {

            } else if self.activeSheet == .createdDirec {
                AddDocGeneView(path: self.masterDirecName, headName: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                AddPdfFileGenView(headPath: self.item.wrappedItemUrl, headName: self.masterDirecName).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .importDoc {
                DocumentPickerView(headPath: self.item.wrappedItemUrl, headName: self.masterDirecName, alertState: self.$showAlert, alertMessage: self.$alertMessage).environment(\.managedObjectContext, self.context)
            }
        }
            
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
            .add(self.searchBar)
        
        .alert(isPresented: $showAlert) {
             Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Dismiss"), action: {
                    print("retry")
                }))
        }
        
    }
    
    // MARK: - Functions
    private func showOptions() {
//        self.showingActionSheet.toggle()
        DispatchQueue.main.async {
            withAnimation {
               self.tapped.toggle()
            }
        }
    }

    private func createDiectory() {
        self.activeSheet = .createdDirec
        self.tapped.toggle()
        self.isShown.toggle()
    }
    
    private func createFile() {
        self.activeSheet = .createPdf
        self.tapped.toggle()
        self.isShown.toggle()
    }
    
    private func toggleSearch() {
        withAnimation {
            self.toggleSearchIcon.toggle()
        }
    }
    
    private func importTapped() {
        self.activeSheet = .importDoc
        self.tapped.toggle()
        self.isShown.toggle()
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        guard let indexToDelete = indexSet.first else { return }
        let item = self.items.first!.fileArray[indexToDelete]
        print(item.wrappedItemUrl)
        if item.itemType == DWDIRECTORY {
            if DWFMAppSettings.shared.deleteSavedFolder(dirname: self.item.wrappedItemUrl, fileName: item.wrappedItemUrl) {
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
            
            if DWFMAppSettings.shared.deleteSavedPdf(direcName: self.item.wrappedItemUrl, fileName: item.wrappedItemUrl) {
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
