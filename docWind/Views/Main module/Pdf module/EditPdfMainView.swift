//
//  EditPdfMainView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/3/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import PDFKit

struct EditPdfMainView: View {
    
    // MARK: - @State properties
    @State private var pdfName = ""
    @State private var selectedIconName = "blue"
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showScanner = false
    @State private var url = ""
    
    // for images
    @State var mainPages: [UIImage] = [UIImage]()
    @State var pages: [UIImage] = [UIImage]()
    @State var pagesWithMark: [UIImage] = [UIImage]()
    
    // addtional properties
    @State private var activeSheet: ActiveOdfMainViewSheet = .scannerView
    @State private var activeAlertSheet: ActiveAlertSheet = .notice
    @State private var removeWatermark = false
    @State private var offsetVal: CGFloat = 0.0
    
    // MARK: - @Environment variables
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // MARK: - Properties
    var iconColors: [Color] = [.blue, .red, .green, .yellow, .pink]
    var iconNameString: [Color: String] = [.blue:"blue", .red:"red", .green:"green", .yellow:"yellow", .pink:"pink"]
    
    // MARK: - Init
    init(pdfName: String, selectedIconName: String, mainPages: [UIImage], url: String) {
        self._pdfName = State(initialValue: pdfName)
        self._selectedIconName = State(initialValue: selectedIconName)
        self._mainPages = State(initialValue: mainPages)
        self._pages = State(initialValue: mainPages)
        self._pagesWithMark = State(initialValue: mainPages)
        self._url = State(initialValue: url)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("File name")) {
                    Text(pdfName)
                }
                
//                Section(header: Text("Choose a file icon")) {
//                    ScrollView(.horizontal) {
//                        HStack {
//                            ForEach(0..<iconColors.count) { index in
//                                VStack {
//                                    Image(systemName: "doc.fill")
//                                        .foregroundColor(self.iconColors[index])
//                                        .font(.body)
//                                        .padding(.bottom)
//                                    if self.selectedIconName == self.iconNameString[self.iconColors[index]]! {
//                                        withAnimation{
//                                            Circle()
//                                                .foregroundColor(.primary)
//                                            .frame(width: 10, height: 10)
//                                                .padding(.bottom)
//                                        }
//                                    }
//                                    }.padding()
//                                .onTapGesture {
//                                    self.selectedIconName = self.iconNameString[self.iconColors[index]]!
//                                }
//                            }
//                        }
//                    }
//                }
                
                Section(header: Text("Add pages?"), footer: Text("Tap on image for more options").isHidden(pages.count == 0)) {
                    if pages.count == 0 {
                        Button(action: addPagesTapped) {
                            Text("Add Pages")
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<((self.removeWatermark == true) ? self.pages.count : self.pagesWithMark.count), id: \.self){ index in
                                    Image(uiImage: ((self.removeWatermark == true) ? self.pages[index] : self.pagesWithMark[index]))
                                    .resizable()
                                    .frame(width: 150, height: 200)
                                    .cornerRadius(8)
                                        .aspectRatio(contentMode: .fill)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                                    .padding()
                                        .onTapGesture {
                                            self.imageTapped()
                                    }
                                }
                                Button(action: {
                                    self.addPagesTapped()
                                }) {
                                    Text("Add more +")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 150, height: 200)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                                    .padding()
                                }
                            }
                        }
                    }
                }
                
               Section(header: Text("Options")){
                    Toggle(isOn: $removeWatermark.didSet(execute: { (status) in
                        if status {
                            if !AppSettings.shared.bougthNonConsumable {
                                self.removeWatermark.toggle()
                                self.activeAlertSheet = .notice
                                self.alertMessage = "You need to be docWind Plus user to access this feature, head over to settings to find out more :)"
                                self.showAlert.toggle()
                            }
                        }
                    })) {
                        HStack {
                            Text("Remove watermark")
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Spacer()
                        }
                    }
                        .onTapGesture {
                            if !AppSettings.shared.bougthNonConsumable {
                              print("You need to buy")
                                self.activeAlertSheet = .notice
                                self.alertMessage = "You need to be docWind Plus user to access this feature, head over to settings to find out more :)"
                                self.showAlert.toggle()
                            }
                    }
                }
                
            }.keyboardSensible(self.$offsetVal)
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
                
            .navigationBarTitle(Text("Edit PDF"))
            .navigationBarItems(leading: Button(action: deleteFile){
                Text("Cancel")
                }, trailing: Button(action:  saveTapped){
                    Text("Save")
            })
        }
        .alert(isPresented: $showAlert) {
                    if self.activeAlertSheet == .notice {
                       return Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .cancel())
                    } else {
                       return Alert(title: Text("Alert"), message: Text("Are you sure you want to delete this document?"), primaryButton: .destructive(Text("Delete"), action: { self.presentationMode.wrappedValue.dismiss() }), secondaryButton: .cancel())
                    }
                }
                .sheet(isPresented: $showScanner) {
                    if self.activeSheet == .scannerView {
                        ScannerView(uiImages: self.$pages, uiImagesWithWatermarks: self.$pagesWithMark)
                    } else if self.activeSheet == .pdfView {
                        SnapCarouselView(imagesState: self.$pages, imageWithWaterMark: self.$pagesWithMark, mainImages: (self.removeWatermark == true) ? self.$pages : self.$pagesWithMark, title: self.pdfName)
                    }
                }
    }
    
    private func saveTapped() {
        FeedbackManager.mediumFeedback()
        
        if (self.pages.count == 0 || self.pagesWithMark.count == 0) {
            self.activeAlertSheet = .notice
            self.alertMessage = "Make sure you have scan atleast one document"
            self.showAlert.toggle()
        } else {
            let mainPages = (self.removeWatermark == true) ? self.pages : self.pagesWithMark
            
            // convert to pdf
            let pdfDocument = PDFDocument()
            for page in mainPages {
                let pdfPage = PDFPage(image: page)
                let index = mainPages.firstIndex(of: page)!
                
                // store in pdfDocument
                pdfDocument.insert(pdfPage!, at: index)
            }
            
            pdfDocument.write(to: URL(string: url)!)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func addPagesTapped() {
        self.activeSheet = .scannerView
        self.showScanner.toggle()
    }
    
    private func imageTapped() {
        self.activeSheet = .pdfView
        self.showScanner.toggle()
    }
    
    private func deleteFile() {
        FeedbackManager.mediumFeedback()
//        self.activeAlertSheet = .delete
//        self.showAlert.toggle()
        self.presentationMode.wrappedValue.dismiss()
    }
}
