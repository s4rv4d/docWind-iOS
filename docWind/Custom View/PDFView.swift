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
     @Binding var options: DrawingTool
     @Binding var canEdit: Bool
     @Binding var color: Color

     let pdfDrawer = PDFDrawer()
     
     let pdfThumbnailView = PDFThumbnailView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 250, width: UIScreen.main.bounds.width, height: 150))
     
    
    func makeUIView(context: UIViewRepresentableContext<PDFCustomView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.fileURL)
        pdfView.backgroundColor = UIColor.lightGray
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displayBox = .mediaBox
        pdfView.displaysAsBook = true
        pdfView.autoScales = true
        print("----------?")

        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFCustomView>) {
        print("STATUS \(canEdit)")
        print(uiView.subviews)
        
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        if canEdit == true {
            print("here")
            uiView.addGestureRecognizer(pdfDrawingGestureRecognizer)
            pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
            pdfDrawer.pdfView = uiView
            pdfDrawer.drawingTool = options
            pdfDrawer.color = color.uiColor()
            
        } else {
            print("adding thumbnail view...")
            print(uiView.gestureRecognizers!.count)
            for recog in uiView.gestureRecognizers! {
                uiView.removeGestureRecognizer(recog)
                if recog == pdfDrawingGestureRecognizer {
                    print("Removing gesture recognizer...")
                    uiView.removeGestureRecognizer(recog)
                }
            }
        }
    }
}

