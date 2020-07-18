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
     @Binding var canEditSignature: Bool
     @Binding var color: Color
    @Binding var saveTapped: Bool
    var image: UIImage?

     let pdfDrawer = PDFDrawer()
     
     let pdfThumbnailView = PDFThumbnailView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 250, width: UIScreen.main.bounds.width, height: 150))
     
    
    func makeUIView(context: UIViewRepresentableContext<PDFCustomView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.fileURL)
        pdfView.backgroundColor = UIColor.lightGray
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displayBox = .mediaBox
//        pdfView.displaysAsBook = true
        pdfView.autoScales = true
        print(pdfView.currentPage!.annotations)
        pdfDrawer.calledOnce = true
        
        pdfDrawer.pdfView = pdfView
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFCustomView>) {
        
        for anno in uiView.currentPage!.annotations {
            if anno.type! == "Stamp" {
                print(anno)
                uiView.currentPage!.addAnnotation(anno)
            }
        }
        
        if saveTapped {
            print(uiView.currentPage!.annotations)
            print(uiView)
            uiView.document?.write(to: fileURL)
        }
        
        print("resetting...")
        for recog in uiView.gestureRecognizers! {
            uiView.removeGestureRecognizer(recog)
        }
        
        // gesture recogs
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        let pdfPanGestureRecognizer = ImagePanGestureRecognizer()
        
        // logic for enabling and disabling
        if canEdit == true {
            if !canEditSignature {
                print("here")
                uiView.addGestureRecognizer(pdfDrawingGestureRecognizer)
                pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
                pdfDrawer.pdfView = uiView
                pdfDrawer.drawingTool = options
                pdfDrawer.color = color.uiColor()
            } else {
                print("since both can edit and edit sign are true , which should not be the case , MAIN PAGE ACTIVE")
                for recog in uiView.gestureRecognizers! {
                    uiView.removeGestureRecognizer(recog)
                }
            }
            
        } else {
            if canEditSignature {
                print("sign will get active")
            } else {
                print("remove everything and add main page as active")
                for recog in uiView.gestureRecognizers! {
                    uiView.removeGestureRecognizer(recog)
                }
            }
        }
        
        // signature part
        if image != nil {
            pdfDrawer.pdfView = uiView
            pdfPanGestureRecognizer.panDelegate = pdfDrawer
            
            if !canEdit  {
                print("here1")
                if canEditSignature {
                    uiView.addGestureRecognizer(pdfPanGestureRecognizer)
                    
                    if !pdfDrawer.calledOnce {
                        let page = uiView.currentPage!
                        let pageBounds = page.bounds(for: .cropBox)
                        let imageBounds = CGRect(x: pageBounds.minX, y: pageBounds.minY, width: 200, height: 100)
                        let imageStamp = ImageStampAnnotation(with: image, forBounds: imageBounds, withProperties: nil)
                        
                        // so that signatures isnt duplicated later on
                        for anno in page.annotations {
                            if anno == imageStamp {
                                page.removeAnnotation(anno)
                            }
                        }
                        
                        page.addAnnotation(imageStamp)
                        pdfDrawer.calledOnce = true
                        
                        if !canEditSignature {
                            for recog in uiView.gestureRecognizers! {
                                uiView.removeGestureRecognizer(recog)
                            }
                        }
                    }
                    
                } else {
                    for recog in uiView.gestureRecognizers! {
                        uiView.removeGestureRecognizer(recog)
                    }
                }
            }
            
        }
        
    }
    
}
