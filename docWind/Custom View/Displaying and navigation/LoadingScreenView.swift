//
//  LoadingScreenView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/18/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct LoadingScreenView: View {
    
    var item: ItemModel
    var uiImages: [UIImage]
    
    @State private var showIndicator = false
    @State private var maxType = 0
    @State private var alertState = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        LoadingView(isShowing: $showIndicator) {
            NavigationView {

                VStack(alignment: .leading) {
                    Text("Max file size:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding([.leading, .trailing, .top])
                    Picker(selection: self.$maxType, label: Text("File size")) {
                        Text("200 KB").tag(0)
                        Text("500 KB").tag(1)
                        Text("1 MB").tag(2)
                    }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                    Spacer()
                    
                    DWButton(text: "Compress file", background: .blue) {
                        self.showIndicator.toggle()
                        
                        var selectedOption = 0
                        
                        switch self.maxType {
                        case 0:
                            selectedOption = KByte_200
                        case 1:
                            selectedOption = KByte_500
                        case 2:
                            selectedOption = MB_1
                        default:
                            selectedOption = KByte_200
                        }
                        print(selectedOption)
                        
                        if DWFMAppSettings.shared.createPDF(images: self.uiImages, maxSize: selectedOption, quality: 100, pdfPathUrl: URL(string: self.item.wrappedItemUrl)) != nil {
                            self.showIndicator.toggle()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.showIndicator.toggle()
                            self.alertState.toggle()
                        }
                        
                    }.padding()
                }

                .navigationBarTitle(Text("Compress file"))
            }
            
            .alert(isPresented: self.$alertState) {
                Alert(title: Text("Error"), message: Text("Error while compressing file"), dismissButton: .default(Text("Dismiss"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                }))
            }
        }
    }
}
