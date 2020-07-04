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
    
    
    // MARK: - Objects
    @ObservedObject var model = MainDocListViewModel()
    
    // MARK: - @Environment variables
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var body: some View {
        VStack {
            CustomNavBarView(action: {
                print("add documents")
                self.showingActionSheet.toggle()
            }, buttonImage: "plus")
                .padding()
            
            //search bar
            SearchBarView(text: $searchBarText)
            .padding(.top, -30)
            
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
                    // display list or grid
                    List {
                        //-----------------------------------------------------------------//
                        //ListCustomGridView(itemArray: self.model.contents!.direcContents)//
                        //-----------------------------------------------------------------//
//                        NormalListRowView(itemArray: self.model.contents!.direcContents)
                        NormalListRowView(itemArray: self.model.contents!.direcContents, activeSheet: $activeSheet, isShown: $isShown)
                        
                    }
                }
            } else {
                Text("Looks empty here, scan a new document using the '+' button above.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                    .padding([.leading, .trailing, .top])
                
//                Text(model.contents!.direcName)
            }
            
            Spacer()
        }
            
        // On appear code
        .onAppear {
                self.check()
        }
            
        // sheet code
        .sheet(isPresented: $isShown) {
            if self.activeSheet == .intro {
                IntroView()
                .environment(\.managedObjectContext, self.context)
            } else if self.activeSheet == .tappedDirec {
                DetailedDirecView()
            } else if self.activeSheet == .tappedPdf {
                DetailPdfView()
            } else if self.activeSheet == .createdDirec {
                AddDirecView()
            }
        }
        
        // action sheet code
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Options"), message: Text("Choose and option"), buttons: [
                .default(Text("Scan a document")) { print("Scan a new document") },
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
    
    func createDiectory() {
        //1. bring up sheet
        self.activeSheet = .createdDirec
        self.isShown.toggle()
        //2. enter detials
        //3. reload list
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
