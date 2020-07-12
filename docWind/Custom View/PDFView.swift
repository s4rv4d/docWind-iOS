//
//  PDFView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/11/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import PDFKit

struct PDFCustomView: UIViewRepresentable {
    
    // MARK: - Properties
    var fileURL: URL
    
    init(_ url: URL) {
        self.fileURL = url
    }
    
    func makeUIView(context: UIViewRepresentableContext<PDFCustomView>) -> PDFCustomView.UIViewType {
        let pdfView = PDFView()
//        let pdfView2 = p
        pdfView.document = PDFDocument(url: self.fileURL)
        pdfView.displayBox = .artBox
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFCustomView>) {
        // Update the view.
    }
}

