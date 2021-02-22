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
    @State var searchString = ""
    @State private var tapped = false
    @State private var isShown = false
    @State private var animationAmount: CGFloat = 1
    @State var activeSheet: ActiveContentViewSheet? = nil
    @State private var presentAlert = false
    @State private var toggleSearchIcon = false
    @State private var item: ItemModel? = nil
    @State var changed = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Error"
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var showAlert = false
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    @AppStorage("isOffgridStyle") var isOffgrid: Bool = false
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: DirecModel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DirecModel.created, ascending: true)], predicate: NSPredicate(format: "name == %@", "DocWind"), animation: .default) var docWindItems: FetchedResults<DirecModel>
    
    // MARK: - ObservedObjects
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    // MARK: - Properties
    var body: some View {
        SearchNavigation(text: $searchString, largeDisplay: true) {
            ZStack {
                VStack(alignment: .leading) {
                    //check if contents isnt empty
                    if self.docWindItems.first != nil {
                        // display contents of file
                        if (self.docWindItems.first!.fileArray.count == 0) {
                            NewStarterView()
                            EmptyView()
                            Color.clear
                        } else {
                            if !self.isOffgrid {
                                List {
                                    Section(header: Text("DocWind >").font(.caption), footer: Text("Tap and hold on a cell for more options").font(.caption)) {
                                        ForEach(self.docWindItems.first!.fileArray.filter { self.searchString.isEmpty || $0.wrappedItemName.localizedStandardContains(self.searchString)}, id: \.self) { item in
                                            NormalListRowView(itemArray: item, masterFolder: "\(DWFMAppSettings.shared.fileURL())")
                                                .environment(\.managedObjectContext, self.context)
                                        }.onDelete(perform: self.deleteRow(at:))
                                    }
                                }
                                .listStyle(InsetGroupedListStyle())
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40, maximum: 50), spacing: 16)], spacing: 8) {
                                    ForEach(self.docWindItems.first!.fileArray.filter { self.searchString.isEmpty || $0.wrappedItemName.localizedStandardContains(self.searchString)}, id: \.self) { file in
                                            QGridCellView(item: file, masterFolder: "\(DWFMAppSettings.shared.fileURL())")
                                                .environment(\.managedObjectContext, self.context)
                                    }
                                }.padding(.horizontal)
                                Spacer()
                            }
                        }
                    } else {
                        NewStarterView()
                        Color.clear
                    }
                }
                                    
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
                            .overlay(
                                Circle()
                                    .stroke(Color(tintColor), lineWidth: 1)
                                    .scaleEffect(self.animationAmount)
                                    .opacity(Double(2 - self.animationAmount))
                                    .animation(
                                        Animation.easeOut(duration: 1)
                                        .repeatCount(10, autoreverses: false)
                                    )
                            )
                        .onAppear {
                            self.animationAmount = 2
                        }
                        .padding()
                    // secondary buttons
                    SecondaryButtonView(tapped: self.$tapped, icon: "folder.fill", color: .green, offsetX: 90, action: self.createDiectory).padding()
                    SecondaryButtonView(tapped: self.$tapped, icon: "camera.fill", color: .pink, offsetY: -90, delay: 0.2, action: self.scanDocumentTapped).padding()
                    SecondaryButtonView(tapped: self.$tapped, icon: "arrow.up.doc.fill", color: .orange, offsetX: -90, delay: 0.4, action: self.importTapped).padding()
                }
            }
                
            .navigationBarTitle(Text("docWind"))
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading:
                Button(action: self.settingsTapped) {
                    SFSymbol.gear
                    .font(.system(size: 20))
                    .foregroundColor(Color(tintColor))
                }, trailing: Button(action: {
                    if let _ = docWindItems.first {
                        if !DWFMAppSettings.shared.syncUpLocalFilesWithApp(direcName: nil, directory: docWindItems.first!, context: self.context) {
                            print("bring up alert")
                            self.alertTitle = "Notice"
                            self.alertMessage = "All local files from Files App(under docWind directory) have been synced up."
                            self.showAlert.toggle()
                        }
                    }
                }) {
                    SFSymbol.goForward
                    .font(.system(size: 20))
                    .foregroundColor(Color(tintColor))
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
                
        // On appear code
        .onAppear {
            
            if let _ = docWindItems.first {
                _ = DWFMAppSettings.shared.syncUpLocalFilesWithApp(direcName: nil, directory: docWindItems.first!, context: self.context)
            }
            
            IAPService.shared.getProducts()
            self.check()
        }
            
        // sheet code
        // make sure to conform to identifiable
        .fullScreenCover(item: $activeSheet, onDismiss: {
            self.activeSheet = nil
        }) { item in
            
            switch item {
            case .intro:
                IntroView()
                    .environment(\.managedObjectContext, self.context)
            case .createdDirec:
                AddDirecView().environment(\.managedObjectContext, self.context)
            case .createPdf:
                AddPdfMainView().environment(\.managedObjectContext, self.context)
            case .settingsTapped:
                SettingsView()
            case .importDoc:
                let str = "\(String("\(DWFMAppSettings.shared.fileURL())".split(separator: "/").last!).trimBothSides())"
                DocumentPickerView(headPath: str, headName: "DocWind", alertState: self.$showAlert, alertMessage: self.$alertMessage).environment(\.managedObjectContext, self.context)
            default:
                EmptyView()
            }
            
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
                self.activeSheet = .intro
//                self.isShown.toggle()
            }
        }
    }
    
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
    
    private func importTapped() {
        self.activeSheet = .importDoc
        self.tapped.toggle()
        self.isShown.toggle()
    }
    
    private func scanDocumentTapped() {
        print("❇️ SCAN DOC TAPPED")
        //bring uo editing page
        self.activeSheet = .createPdf
        self.tapped.toggle()
        self.isShown.toggle()
        //add pages and saves
    }
    
    private func settingsTapped() {
        FeedbackManager.mediumFeedback()
        self.activeSheet = .settingsTapped
        self.isShown.toggle()
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        guard let indexToDelete = indexSet.first else { return }
        let item = self.docWindItems.first!.fileArray[indexToDelete]
        
        
        if item.itemType == DWDIRECTORY {
            
            var folderName = item.wrappedItemName
            
            if folderName.contains(" ") {
                folderName = folderName.replacingOccurrences(of: " ", with: "_")
            }
            
            guard folderName != "DocWind" else {
                return
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
                
                ItemModel.deleteObject(in: context, sub: item)
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "Couldnt delete file"
                self.showAlert.toggle()
            }
        }
    }
}

