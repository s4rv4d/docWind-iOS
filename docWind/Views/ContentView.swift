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
    @State var activeSheet: ActiveContentViewSheet = .intro
    @State private var presentAlert = false
    @State private var toggleSearchIcon = false
    @State private var item: ItemModel? = nil
    @State var changed = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Error"
    @State private var alertContext: ActiveAlertSheet = .error
    @State private var showAlert = false
    @State private var isOffgrid = false
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: DirecModel.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DirecModel.created, ascending: true)], predicate: NSPredicate(format: "name == %@", "DocWind"), animation: .default) var items: FetchedResults<DirecModel>
    
    // MARK: - ObservedObjects
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    // MARK: - Properties
    var body: some View {
        SearchNavigation(text: $searchString, largeDisplay: true) {
            ZStack {
                VStack(alignment: .leading) {
                    //check if contents isnt empty
                    if self.items.first != nil {
                        // display contents of file
                        if (self.items.first!.fileArray.count == 0) {
                            NewStarterView()
                            EmptyView()
                            Color.clear
                        } else {
                            if !self.isOffgrid {
                                List {
                                    Section(header: Text("DocWind >").font(.caption), footer: Text("Tap and hold on a cell for more options").font(.caption)) {
                                        ForEach(self.items.first!.fileArray.filter { self.searchString.isEmpty || $0.wrappedItemName.localizedStandardContains(self.searchString)}, id: \.self) { item in
                                            NormalListRowView(itemArray: item, masterFolder: "\(DWFMAppSettings.shared.fileURL())")
                                                .environment(\.managedObjectContext, self.context)
                                        }.onDelete(perform: self.deleteRow(at:))
                                    }
                                }
                                .listStyle(GroupedListStyle())
                            } else {
                                // replace this with grid view layout
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
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 1)
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
                    Image(systemName: "gear")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                }, trailing: Button(action: {
                    self.isOffgrid.toggle()
                }){
                    Image(systemName: (self.isOffgrid == false ? "rectangle.3.offgrid" : "rectangle.grid.1x2"))
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
            })
//            .add(self.searchBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
            
                
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
            } else if self.activeSheet == .importDoc {
                DocumentPickerView(headPath: "\(DWFMAppSettings.shared.fileURL())", headName: "DocWind", alertState: self.$showAlert, alertMessage: self.$alertMessage).environment(\.managedObjectContext, self.context)
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
                self.isShown.toggle()
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
        let item = self.items.first!.fileArray[indexToDelete]
        
        
        if item.itemType == DWDIRECTORY {
            if DWFMAppSettings.shared.deleteSavedFolder(dirname: "\(DWFMAppSettings.shared.fileURL())", fileName: item.wrappedItemUrl) {
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
            if DWFMAppSettings.shared.deleteSavedPdf(direcName: "\(DWFMAppSettings.shared.fileURL())", fileName: item.wrappedItemUrl) {
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

