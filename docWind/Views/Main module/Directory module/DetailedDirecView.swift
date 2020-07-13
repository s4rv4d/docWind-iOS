//
//  DetailedDirecView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct DetailedDirecView: View {
    
    // MARK: - @State variables
    @State var item: ItemModel
    @State private var isShown = false
    @State var searchBarText = ""
    @State private var showingActionSheet = false
    @State var activeSheet: ActiveContentViewSheet = .intro
    @State private var presentAlert = false
    @State private var toggleSearchIcon = false
    @State var masterFolder: String
    
    // MARK: - Objects
    @ObservedObject var model: GeneralDocListViewModel
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var body: some View {
        VStack(alignment: .leading) {
            //check if contents isnt empty
            if model.contents != nil {
                // display contents of file
                if (model.contents!.direcContents.count == 0) {
                    Text("Looks empty here, scan a new document or create a new dierctory using the '+' button above.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                        .padding([.leading, .trailing, .top])
                } else {
                    // display list or gridSearchBarView(text: $searchBarText)
                    if toggleSearchIcon {
                        SearchBarView(text: $searchBarText)
                            .padding(.top)
                    }
                    List {
                        
                        Section(header: Text("\(String(masterFolder.split(separator: "/").last!)) > \(item.wrappedItemName)").font(.caption)) {
     //-----------------------------------------------------------------//
//                                ListCustomGridView(itemArray: self.model.contents!.direcContents)
                            //-----------------------------------------------------------------//
                            NormalListRowView(itemArray: self.model.contents!.direcContents, masterFolder: item.wrappedItemUrl, activeSheet: $activeSheet, isShown: $isShown)
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
                AddDocGeneView(headName: self.item.wrappedItemUrl, model: self.model).environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .createPdf {
                AddPdfFileGenView(headPath: self.item.wrappedItemUrl, model: self.model).environment(\.managedObjectContext, self.context)
            }
        }
            
        .navigationBarTitle(Text(item.wrappedItemName), displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarItems(trailing:
            
            HStack{
                #warning("add later")
//                Button(action: toggleSearch) {
//                    Image(systemName: "magnifyingglass")
//                    .font(.system(size: 25))
//                }
//                Spacer()
                Button(action: showOptions){
                    Image(systemName: "plus")
                        .font(.system(size: 25))
                        }
            }
        )
        
        // action sheet code
       .actionSheet(isPresented: $showingActionSheet) {
           ActionSheet(title: Text("Options"), message: Text("Choose and option"), buttons: [
               .default(Text("Scan a document"), action: createFile),
               .default(Text("Create a new directory"), action: createDiectory),
               .cancel()
           ])
       }
        
    }
    
    // MARK: - Functions
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
    
    func createFile() {
        self.activeSheet = .createPdf
        self.isShown.toggle()
    }
    
    func toggleSearch() {
        withAnimation {
            self.toggleSearchIcon.toggle()
        }
        
    }
}
