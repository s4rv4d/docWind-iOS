//
//  UpdateUIView.swift
//  docWind
//
//  Created by Sarvad Shetty on 22/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct UpdateUIView: View {
    
    @State private var color: String = ""
    @State private var showAlert: Bool = false
    
    @AppStorage("mainAppColor") var tintColor: String = "Light Blue"
    @AppStorage("isOffgridStyle") var isOffgrid: Bool = false
    @AppStorage("lang") var lang: String = "en"
    
    @Environment(\.presentationMode) var presentationMode
    
    let colorColumns = [GridItem(.adaptive(minimum: 44))]
    let colors = ["Pink", "Purple", "Red", "Gold", "Orange", "Green", "Teal", "Light Blue", "Dark Blue", "Midnight", "Dark Gray", "Gray"]
    
    init() {
        self._color = State(wrappedValue: self.tintColor)
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Content display type")) {
                        HStack {
                            SFSymbol.recGrid1x2
                                .foregroundColor(.blue)
                                .padding(.trailing, 9)
                            Text("List View")
                            Spacer()
                            SFSymbol.checkmarkSealFill
                                .foregroundColor(.green)
                                .isHidden(!isOffgrid == false)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: tappedListView)
                        
                        HStack {
                            SFSymbol.rec3Offgrid
                                .foregroundColor(.blue)
                                .padding(.trailing, 5)
                            Text("Grid View")
                            Spacer()
                            SFSymbol.checkmarkSealFill
                                .foregroundColor(.green)
                                .isHidden(isOffgrid == false)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: tappedGridView)
                    }
                    
                    Section(header: Text("App Tint")) {
                        LazyVGrid(columns: colorColumns) {
                            ForEach(colors, id: \.self) { item in
                                ZStack {
                                    Color(item)
                                        /// aspect ratio of 1 turns it into square
                                        .aspectRatio(1, contentMode: .fit)
                                        .cornerRadius(6)
                                    if item == color {
                                        SFSymbol.checkmarkCircle
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                    }
                                }
                                .onTapGesture {
                                    self.color = item
                                    self.tintColor = item
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityAddTraits(
                                    item == color
                                        ? [.isButton, .isSelected]
                                        : .isButton
                                )
                                .accessibilityLabel(LocalizedStringKey(item))
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Section(header: Text("Languages"), footer: Text("More languages support to come soon")) {
                        HStack {
                            SFSymbol.personFill
                                .foregroundColor(.blue)
                                .padding(.trailing, 9)
                            Text("English")
                            Spacer()
                            SFSymbol.checkmarkSealFill
                                .foregroundColor(.green)
                                .isHidden(!(lang == "en"))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: {
                            langSet(lg: "en")
                        })
                        
                        HStack {
                            SFSymbol.personFill
                                .foregroundColor(.orange)
                                .padding(.trailing, 5)
                            Text("Hindi")
                            Spacer()
                            SFSymbol.checkmarkSealFill
                                .foregroundColor(.green)
                                .isHidden(!(lang == "hi"))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: {
                            langSet(lg: "hi")
                        })
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notice"), message: Text("In order to change the language, make sure to wait for a few seconds and close and reopen the app."), dismissButton: .default(Text("Dismiss")))
            }
            .navigationTitle(Text("Update UI"))
            .navigationBarItems(trailing:
                                    Button(action:{
                                        self.presentationMode.wrappedValue.dismiss()
                                    }){
                                        SFSymbol.multiplyCircleFill
                                            .foregroundColor(Color(tintColor))
                                            .font(.system(size: 25))
                                    }
                                )
        }
    }
    
    // MARK: - Functions
    func tappedListView() {
        isOffgrid = false
    }
    
    func tappedGridView() {
        isOffgrid = true
    }
    
    func langSet(lg: String) {
        lang = lg
        UserDefaults.standard.set([lg], forKey: "AppleLanguages")
        self.showAlert.toggle()
    }
}

struct UpdateUIView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateUIView()
    }
}
