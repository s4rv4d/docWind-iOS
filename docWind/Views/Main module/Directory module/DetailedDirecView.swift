//
//  DetailedDirecView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData
import QGrid

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
    @State private var isOffgrid = false
    
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
            ZStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            //check if contents isnt empty
                            if self.items.first != nil {
                                // display contents of file
                                if (self.items.first?.fileArray.count == 0) {
                                    Text("Looks empty here, scan a new document or create a new directory using the '+' button above.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                        .padding([.leading, .trailing, .top])
                                    Color.clear
                                } else {
                                    if !self.isOffgrid {
                                        List {
                                            Section(header: Text("\(String(self.masterFolder.split(separator: "/").last!)) > \(self.item.wrappedItemName)").font(.caption), footer: Text("Tap and hold on cell for more options").font(.caption)) {
                                                ForEach(self.items.first!.fileArray.filter {
                                                    self.searchBar.text.isEmpty ||
                                                        $0.wrappedItemName.localizedStandardContains(self.searchBar.text)
                                                }, id: \.self){ item in
                                                    GenListRowView(itemArray: item, masterFolder: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
                                                }.onDelete(perform: self.deleteRow(at:))
                                            }
                                        }
                                        .listStyle(GroupedListStyle())
                                        .add(self.searchBar)
                                    } else {
                                        // replace this with grid view layout
                                        GeometryReader { geometry in
                                            ZStack {
                                                self.gridView(geometry, items: self.items.first!.fileArray.filter {
                                                    self.searchBar.text.isEmpty ||
                                                        $0.wrappedItemName.localizedStandardContains(self.searchBar.text)
                                                }).padding(.top)
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("Looks empty here, scan a new document using the '+' button above.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                    .padding([.leading, .trailing, .top])
                                Color.clear
                            }
                        }
                        
                        // button
                        ZStack(alignment: .bottom) {
                            Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            Button(action: self.showOptions) {
                                Image(systemName: "plus")
                                    .rotationEffect(.degrees(self.tapped ? 45 : 0))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0))
                                }
                                .padding(24)
                                .background(Color.blue)
                                .mask(Circle())
                                .animation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0))
                                .zIndex(10)
                                .padding()
                            // secondary buttons
                            SecondaryButtonView(tapped: self.$tapped, icon: "folder.fill", color: .green, offsetX: 90, action: self.createDiectory).padding()
                            SecondaryButtonView(tapped: self.$tapped, icon: "camera.fill", color: .pink, offsetY: -90, delay: 0.2, action: self.createFile).padding()
                            SecondaryButtonView(tapped: self.$tapped, icon: "arrow.up.doc.fill", color: .orange, offsetX: -90, delay: 0.4, action: self.importTapped).padding()
                        }
                    }
                    // sheet code
        .navigationBarTitle(Text(self.item.wrappedItemName), displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing: Button(action: {
            FeedbackManager.mediumFeedback()
                self.isOffgrid.toggle()
            }){
                Image(systemName: (self.isOffgrid == false ? "rectangle.3.offgrid" : "rectangle.grid.1x2"))
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
        })
        
        .alert(isPresented: $showAlert) {
             Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Dismiss"), action: {
                    print("retry")
                }))
        }
        
        .sheet(isPresented: $isShown) {
            if self.activeSheet == .createdDirec {
                AddDocGeneView(path: self.masterDirecName, headName: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                AddPdfFileGenView(headPath: self.item.wrappedItemUrl, headName: self.masterDirecName).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .importDoc {
                DocumentPickerView(headPath: self.item.wrappedItemUrl, headName: self.masterDirecName, alertState: self.$showAlert, alertMessage: self.$alertMessage).environment(\.managedObjectContext, self.context)
            }
        }
        
    }
    
    // MARK: - Functions
    private func showOptions() {
        FeedbackManager.mediumFeedback()
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
    
    private func gridView(_ geometry: GeometryProxy, items: [ItemModel]) -> some View {
        QGrid(items,
              columns: 4,
              columnsInLandscape: 0,
              vSpacing: 8,
              hSpacing: 16,
              vPadding: 0,
              hPadding: 10) {
                QGridCellView(item: $0, masterFolder: self.item.wrappedItemUrl)
                .environment(\.managedObjectContext, self.context)
        }
    }
}
