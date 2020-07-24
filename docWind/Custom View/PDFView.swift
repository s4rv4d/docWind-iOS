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
    var options: DrawingTool
    var canEdit: Bool
    var canEditSignature: Bool
    var color: Color
    var saveTapped: Bool
    var image: UIImage?
    @Binding var alreadyAdded: Bool

    let pdfDrawer = PDFDrawer()
    let pdfThumbnailView = PDFThumbnailView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 250, width: UIScreen.main.bounds.width, height: 150))
     
    
    func makeUIView(context: UIViewRepresentableContext<PDFCustomView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.fileURL)
        pdfView.backgroundColor = UIColor.lightGray
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displayBox = .mediaBox
        pdfView.autoScales = true
        pdfView.interpolationQuality = .high
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFCustomView>) {
        
        pdfDrawer.pdfView = uiView
        
        if saveTapped {
            print(uiView.currentPage!.annotations)
            print(uiView)
            uiView.document?.write(to: fileURL)
        }
        
        print("resetting switching back to page gesture")
        for recog in uiView.gestureRecognizers! {
            uiView.removeGestureRecognizer(recog)
        }
        
        // gesture recogs
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        let pdfPanGestureRecognizer = ImagePanGestureRecognizer()
        
        // logic for enabling and disabling
        if canEdit == true {
            if !canEditSignature {
                uiView.addGestureRecognizer(pdfDrawingGestureRecognizer)
                pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
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
            print("😁 received image")            
            pdfPanGestureRecognizer.panDelegate = pdfDrawer
            
            if !canEdit  {
                if canEditSignature {
                    print("adding image pan gesture")

                    
                    if !pdfDrawer.calledOnce {
                        let page = uiView.currentPage!
                        let pageBounds = page.bounds(for: .cropBox)
                        let imageBounds = CGRect(x: pageBounds.minX, y: pageBounds.minY, width: 200, height: 100)
                        let imageStamp = ImageStampAnnotation(with: image, forBounds: imageBounds, withProperties: nil)

//                         so that signatures isnt duplicated later on
                        if page.annotations.last! == imageStamp {
                            page.removeAnnotation(page.annotations.last!)
                        }

                        page.addAnnotation(imageStamp)

                        for recog in uiView.gestureRecognizers! {
                            uiView.removeGestureRecognizer(recog)
                        }
                        uiView.addGestureRecognizer(pdfPanGestureRecognizer)
                        print(uiView.gestureRecognizers!)
                        pdfDrawer.calledOnce = true
                    } else {
                        for recog in uiView.gestureRecognizers! {
                            uiView.removeGestureRecognizer(recog)
                        }
                        uiView.addGestureRecognizer(pdfPanGestureRecognizer)
                    }
                    
                } else {
                    print("if both arent true remove all gesture and stick to main page ges")
                    for recog in uiView.gestureRecognizers! {
                        uiView.removeGestureRecognizer(recog)
                    }
                }
            } else {
                print("CAN EDIT ON")
            }
            
            if alreadyAdded {
                let page = uiView.currentPage!
                page.removeAnnotation(page.annotations.last!)
                let pageBounds = page.bounds(for: .cropBox)
                let imageBounds = CGRect(x: pageBounds.minX, y: pageBounds.minY, width: 200, height: 100)
                let imageStamp = ImageStampAnnotation(with: image, forBounds: imageBounds, withProperties: nil)
                page.addAnnotation(imageStamp)
                uiView.addGestureRecognizer(pdfPanGestureRecognizer)
            }
            
        } else {
            print("no image")
        }
        
    }
    
}
