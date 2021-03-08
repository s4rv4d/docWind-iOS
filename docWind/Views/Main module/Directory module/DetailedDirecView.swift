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
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    @AppStorage("isOffgridStyle") var isOffgrid: Bool = false
    @ObservedObject var item: ItemModel
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
    @FetchRequest var directory: FetchedResults<DirecModel>
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    
    // MARK: - ObservedObjects
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    init(dirName: String, pathName: String, item: ItemModel) {
        self._masterDirecName = State(initialValue: dirName)
        self._masterFolder = State(initialValue: pathName)
        self.item = item
        
        self._directory = FetchRequest(
            entity: DirecModel.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "name == %@", "\(dirName)"), animation: .default)
    }
    
    // MARK: - Properties
    var body: some View {
        ZStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        //check if contents isnt empty
                        if self.directory.first != nil {
                            // display contents of file
                            if (self.directory.first?.fileArray.count == 0) {
                                Text("Looks empty here, scan a new document or create a new directory using the '+' button above.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                    .padding([.leading, .trailing, .top])
                                Color.clear
                            } else {
                                if !self.isOffgrid {
                                    if #available(iOS 14.0, *) {
                                        List {
                                            Section(header: Text("DocWind > \(self.item.wrappedItemName)").font(.caption), footer: Text("Tap and hold on an item for more options").font(.caption)) {
                                                ForEach(self.directory.first!.fileArray.filter {
                                                    self.searchBar.text.isEmpty ||
                                                        $0.wrappedItemName.localizedStandardContains(self.searchBar.text)
                                                }, id: \.self){ item in
                                                    GenListRowView(itemArray: item, masterFolder: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
                                                }.onDelete(perform: self.deleteRow(at:))
                                            }
                                        }
                                        .listStyle(InsetGroupedListStyle())
                                        .add(self.searchBar)
                                    } else {
                                        // Fallback on earlier versions
                                        List {
                                            Section(header: Text("\(String(self.masterFolder.split(separator: "/").last!)) > \(self.item.wrappedItemName)").font(.caption), footer: Text("Tap and hold on an item for more options").font(.caption)) {
                                                ForEach(self.directory.first!.fileArray.filter {
                                                    self.searchBar.text.isEmpty ||
                                                        $0.wrappedItemName.localizedStandardContains(self.searchBar.text)
                                                }, id: \.self){ item in
                                                    GenListRowView(itemArray: item, masterFolder: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
                                                }.onDelete(perform: self.deleteRow(at:))
                                            }
                                        }
                                        .listStyle(GroupedListStyle())
                                        .add(self.searchBar)

                                    }
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 35) {
                                        ForEach(self.directory.first!.fileArray.filter { self.searchBar.text.isEmpty || $0.wrappedItemName.localizedStandardContains(self.searchBar.text)}, id: \.self) { file in
                                            QGridCellView(item: file, masterFolder: self.item.wrappedItemUrl)
                                            .environment(\.managedObjectContext, self.context)
                                        }
                                    }
                                    .padding(.top, 10)
                                    Spacer()
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
                            SFSymbol.plus
                                .rotationEffect(.degrees(self.tapped ? 45 : 0))
                                .foregroundColor(.white)
                                .font(.title)
                                .animation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0))
                            }
                            .padding(24)
                            .background(Color(tintColor))
                            .mask(Circle())
                            .animation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0))
                            .zIndex(10)
                            .padding()
                        // secondary buttons
                        SecondaryButtonView(tapped: self.$tapped, icon: "camera.fill", color: .pink, offsetX: 45, offsetY: -90, delay: 0.2, action: self.createFile).padding()
                        SecondaryButtonView(tapped: self.$tapped, icon: "arrow.up.doc.fill", color: .orange, offsetX: -45, offsetY: -90, delay: 0.4, action: self.importTapped).padding()
                    }
                }
        .onAppear {
            
            if let _ = directory.first {
                _ = DWFMAppSettings.shared.syncUpLocalFilesWithApp(direcName: masterDirecName, directory: directory.first!, context: self.context)
            }
        }
        // sheet code
        .navigationBarTitle(Text(self.item.wrappedItemName), displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing: Button(action: {
            if let _ = directory.first {
                if !DWFMAppSettings.shared.syncUpLocalFilesWithApp(direcName: masterDirecName, directory: directory.first!, context: self.context) {
                    print("bring up alert")
                    self.alertTitle = "Notice"
                    self.alertMessage = "All local files from Files App(under docWind/\(masterDirecName) directory) have been synced up."
                    self.showAlert.toggle()
                }
            }
        }) {
            SFSymbol.goForward
            .font(.system(size: 20))
            .foregroundColor(Color(tintColor))
        })
        
        .alert(isPresented: $showAlert) {
             Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .cancel(Text("Dismiss"), action: {
                    print("retry")
                }))
        }
        
        .fullScreenCover(isPresented: $isShown) {
            if self.activeSheet == .createdDirec {
                AddDocGeneView(path: self.masterDirecName, headName: self.item.wrappedItemUrl).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                let str = "\(String(self.item.wrappedItemUrl.split(separator: "/").last!).trimBothSides())"
                AddPdfFileGenView(headPath: str, headName: self.masterDirecName).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .importDoc {
                
                let str = "\(String(self.item.wrappedItemUrl.split(separator: "/").last!).trimBothSides())"
                DocumentPickerView(headPath: str, headName: self.masterDirecName, alertState: self.$showAlert, alertMessage: self.$alertMessage).environment(\.managedObjectContext, self.context)
                
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
        let item = self.directory.first!.fileArray[indexToDelete]
        print(item.wrappedItemUrl)
        if item.itemType == DWDIRECTORY {
            
            var folderName = item.wrappedItemName
            
            if folderName.contains(" ") {
                folderName = folderName.replacingOccurrences(of: " ", with: "_")
            }
            
            if DWFMAppSettings.shared.deleteSavedFolder(folderName: folderName) {
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
            
            let ref = "\(item.wrappedItemUrl.split(separator: "/").reversed()[1])".trimBothSides()
            
            var fileName = item.wrappedItemName
            
            if fileName.contains(" ") {
                fileName = fileName.replacingOccurrences(of: " ", with: "_")
            }
            
            if !fileName.contains(".pdf") {
                fileName += ".pdf"
            }
            
            if DWFMAppSettings.shared.deleteSavedPdf(direcName: (ref == "DocWind") ? nil : ref, fileName: fileName) {
                print("SUCCESSFULLY DELETED FROM iCloud container ✅")
                
                DispatchQueue.global(qos: .userInitiated).async {
                    ItemModel.deleteObject(in: context, sub: item)
                }
                
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "Couldnt delete file"
                self.showAlert.toggle()
            }

        }
    }
}
