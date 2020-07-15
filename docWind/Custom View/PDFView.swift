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
    @State var fileURL: URL
    @Binding var options: DrawingTool
    @Binding var canEdit: Bool
    @Binding var color: Color

    private let pdfDrawer = PDFDrawer()
    private let pdfThumbnailView = PDFThumbnailView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: UIScreen.main.bounds.width, height: 150))
    private let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
    
    func makeUIView(context: UIViewRepresentableContext<PDFCustomView>) -> PDFCustomView.UIViewType {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.fileURL)
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displayBox = .mediaBox
        pdfView.displaysAsBook = true
        pdfView.autoScales = true
        
        
       let thumbnailSize: Int = 50
       pdfThumbnailView.translatesAutoresizingMaskIntoConstraints = false
       pdfThumbnailView.pdfView = pdfView
       pdfThumbnailView.backgroundColor = .clear
       pdfThumbnailView.layoutMode = .horizontal
       pdfThumbnailView.thumbnailSize = CGSize(width: thumbnailSize, height: thumbnailSize)
       pdfView.addSubview(pdfThumbnailView)
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFCustomView>) {
        print("STATUS \(canEdit)")
        if canEdit == true {
            print("here")
            for view in uiView.subviews {
                print(view)
                if view == pdfThumbnailView {
                    print("removing pdf thumbnail view...")
                    view.removeFromSuperview()
                }
            }
            
            print("adding gesture recognizer...")
            uiView.addGestureRecognizer(pdfDrawingGestureRecognizer)
            pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
            pdfDrawer.pdfView = uiView
            pdfDrawer.drawingTool = options
            pdfDrawer.color = color.uiColor()
            
        } else {
            print("adding thumbnail view...")
            pdfThumbnailView.backgroundColor = .clear
//            uiView.addSubview(pdfThumbnailView)
            for recog in uiView.gestureRecognizers! {
                if recog == pdfDrawingGestureRecognizer {
                    print("Removing gesture recognizer...")
                    uiView.removeGestureRecognizer(recog)
                }
            }
        }
    }
}

