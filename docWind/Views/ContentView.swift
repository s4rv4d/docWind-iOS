//
//  ContentView.swift
//  docWind
//
//  Created by Sarvad shetty on 6/30/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: - @State variables
    @State private var isShown = false
    @State var searchBarText = ""
    @State private var showingActionSheet = false
    @State var activeSheet: ActiveContentViewSheet = .intro
    @State private var presentAlert = false
    @State private var toggleSearchIcon = false

    
    // MARK: - Objects
    @ObservedObject var model = MainDocListViewModel()
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var body: some View {
        NavigationView {
                    VStack(alignment: .leading) {
                        //check if contents isnt empty
                        if model.contents != nil {
                            // display contents of file
                            if (model.contents!.direcContents.count == 0) {
//                                Text("Looks empty here, scan a new document or create a new dierctory using the '+' button above.")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                                .multilineTextAlignment(.center)
//                                    .padding([.leading, .trailing, .top])
                                 NewStarterView()
                                .padding()
                            } else {
                                // display list or gridSearchBarView(text: $searchBarText)
//                                if toggleSearchIcon {
//                                    #warning("add later")
//                                    SearchBarView(text: $searchBarText)
//                                    .isHidden(!toggleSearchIcon)
//                                }
                               
                                List {
                                    
                                    Section(header: Text("DocWind >").font(.caption)) {
                    //-----------------------------------------------------------------//
        //                                ListCustomGridView(itemArray: self.model.contents!.direcContents)
                                        //-----------------------------------------------------------------//
                                        NormalListRowView(itemArray: self.model.contents!.direcContents, masterFolder: "\(DWFMAppSettings.shared.fileURL())", activeSheet: $activeSheet, isShown: $isShown)
                                    }
                                    
                                }
                                .listStyle(GroupedListStyle())
                            }
                        } else {
                            Text("Looks empty here, scan a new document using the 'add' button above.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                                .padding([.leading, .trailing, .top])
                        }
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "gear")
                                .font(.body)
                                .foregroundColor(.blue)
                            .padding()
                                .onTapGesture {
                                    self.settingsTapped()
                            }
                        }.background(Color(.secondarySystemBackground))
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
                AddDirecView(model: self.model).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                AddPdfMainView(model: self.model).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .settingsTapped {
                SettingsView()
            }
        }
        
        // action sheet code
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Options"), message: Text("Choose and option"), buttons: [
                .default(Text("Scan a document"), action: scanDocumentTapped),
                .default(Text("Create a new directory"), action: createDiectory),
                .cancel()
            ])
        }
    }
    
    // MARK: - Functions
    func check() {
        print(AppSettings.shared.firstLoginDone)
        if !AppSettings.shared.firstLoginDone {
            if Device.IS_IPAD || Device.IS_IPHONE{
                self.isShown.toggle()
            }
        }
    }
    
    func showOptions() {
        self.showingActionSheet.toggle()
    }
    
    func createDiectory() {
        //1. bring up sheet
        self.activeSheet = .createdDirec
        self.isShown.toggle()
        //2. enter detials
        //3. reload list
    }
    
    func toggleSearch() {
//        withAnimation {
//            self.toggleSearchIcon.toggle()
//        }
//
    }
    
    func scanDocumentTapped() {
        print("❇️ SCAN DOC TAPPED")
        //bring uo editing page
        self.activeSheet = .createPdf
        self.isShown.toggle()
        //add pages and saves
    }
    
    func settingsTapped() {
        self.activeSheet = .settingsTapped
        self.isShown.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
