//
//  AddPdfMainView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/6/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct AddPdfMainView: View {
    
    // MARK: - @State properties
    @State private var pdfName = "Document"
    @State private var selectedIconName = "blue"
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showScanner = false
    @State var pages: [UIImage] = [UIImage]()
    @State var pagesWithMark: [UIImage] = [UIImage]()
    @State var pageImages: [Image] = [Image]()
    @State private var activeSheet: ActiveOdfMainViewSheet = .scannerView
    @State private var activeAlertSheet: ActiveAlertSheet = .notice
    @State private var removeWatermark = false
    @State var deleteDoc = false
    
    // MARK: - Object
    @ObservedObject var model: MainDocListViewModel // will use for saving stuff
    @ObservedObject var recognizedText: RecognizedText = RecognizedText()
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var iconColors: [Color] = [.blue, .red, .green, .yellow, .pink]
    var iconNameString: [Color: String] = [.blue:"blue", .red:"red", .green:"green", .yellow:"yellow", .pink:"pink"]
    
    var body: some View {
        NavigationView {
            
            // contents
            Form {
                Section(header: Text("File name")) {
                    TextField("Enter a name", text: $pdfName)
                }
                
                Section(header: Text("Choose a file icon")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<iconColors.count) { index in
                                VStack {
                                    Image(systemName: "doc.fill")
                                        .foregroundColor(self.iconColors[index])
                                        .font(.body)
                                        .padding(.bottom)
                                    if self.selectedIconName == self.iconNameString[self.iconColors[index]]! {
                                        withAnimation{
                                            Circle()
                                                .foregroundColor(.primary)
                                            .frame(width: 10, height: 10)
                                                .padding(.bottom)
                                        }
                                    }
                                    }.padding()
                                .onTapGesture {
                                    self.selectedIconName = self.iconNameString[self.iconColors[index]]!
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Add pages?")) {
                    if pages.count == 0 {
                        Button(action: addPagesTapped) {
                            Text("Add Pages")
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<self.pages.count){ index in
                                    Image(uiImage: self.pages[index])
                                    .resizable()
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(8)
                                        .aspectRatio(contentMode: .fill)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white))
                                    .padding()
                                        .onTapGesture {
                                            self.imageTapped()
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Options")){
                    Toggle(isOn: $removeWatermark) {
                        HStack {
                            Text("Remove watermark")
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Spacer()
                        }
                    }
                }
            }
            
                .navigationBarTitle(Text(self.pdfName))
            .navigationBarItems(leading: Button(action: deleteFile){
                Text("Delete")
                    .foregroundColor(.red)
                }, trailing: Button(action:  saveTapped){
                    Text("Save")
            })
        }
        .alert(isPresented: $showAlert) {
            if self.activeAlertSheet == .notice {
               return Alert(title: Text("Notice"), message: Text(alertMessage), primaryButton: .cancel(), secondaryButton: .default(Text("Retry")))
            } else {
               return Alert(title: Text("Alert"), message: Text("Are you sure you want to delete this document?"), primaryButton: .destructive(Text("Delete"), action: { self.presentationMode.wrappedValue.dismiss() }), secondaryButton: .cancel())
            }
        }
        .sheet(isPresented: $showScanner) {
            if self.activeSheet == .scannerView {
                ScannerView(uiImages: self.$pages, uiImagesWithWatermarks: self.$pagesWithMark)
            } else if self.activeSheet == .pdfView {
                SnapCarouselView(images: (self.removeWatermark == true) ? self.pages : self.pagesWithMark, title: self.pdfName, delete: self.$deleteDoc).environment(\.managedObjectContext, self.context)
            }
        }
    }
    
    // MARK: - Functions
    private func saveTapped() {
        
        if (self.pages.count == 0 || self.pagesWithMark.count == 0) {
            self.activeAlertSheet = .notice
            self.alertMessage = "Make sure you have scan atleast one document"
            self.showAlert.toggle()
        } else {
            
            #warning("befire going file save using vm")
            self.activeSheet = .pdfView
            self.showScanner.toggle()
        }
    }
    
    private func addPagesTapped() {
        self.showScanner.toggle()
    }
    
    private func imageTapped() {
        self.activeSheet = .pdfView
        self.showScanner.toggle()
    }
    
    private func deleteFile() {
        self.activeAlertSheet = .delete
        self.showAlert.toggle()
    }
}
