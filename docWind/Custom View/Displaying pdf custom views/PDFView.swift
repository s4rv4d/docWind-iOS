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
    var fileURL: String
    var options: DrawingTool
    var canEdit: Bool
    var canEditSignature: Bool
    var color: Color
    var saveTapped: Bool
    var image: UIImage?
    @Binding var alreadyAdded: Bool

    let pdfDrawer = PDFDrawer()
    let pdfThumbnailView = PDFThumbnailView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 250, width: UIScreen.main.bounds.width, height: 100))
     
    
    func makeUIView(context: UIViewRepresentableContext<PDFCustomView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: URL(string: self.fileURL)!)
        pdfView.backgroundColor = UIColor.lightGray
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displayBox = .mediaBox
        pdfView.autoScales = true
        pdfView.interpolationQuality = .high
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFCustomView>) {
        
        // assignig pdfDrawer
        pdfDrawer.pdfView = uiView
        
        // setting pdfThumbnailView
        pdfThumbnailView.pdfView = uiView
        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.thumbnailSize = CGSize(width: 60, height: 60)
        pdfThumbnailView.backgroundColor = .clear
        
        // saving happens here
        if saveTapped {
            print(uiView.currentPage!.annotations)
            print(uiView)
            uiView.document?.write(to: URL(string: fileURL)!)
        }

        print("resetting switching back to page gesture")
        for recog in uiView.gestureRecognizers! {
            uiView.removeGestureRecognizer(recog)
        }
        
        // removing and reapplying thumbnails to prevents duplicates
        for view in uiView.subviews {
            if view.isKind(of: PDFThumbnailView.self) {
                view.removeFromSuperview()
            }
        }
        uiView.addSubview(pdfThumbnailView)
        
        // gesture recogs
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        let pdfPanGestureRecognizer = ImagePanGestureRecognizer()
        
        // logic for enabling and disabling
        if canEdit == true {
            if !canEditSignature {
                print(uiView.subviews)
                for view in uiView.subviews {
                    if view.isKind(of: PDFThumbnailView.self) {
                        view.removeFromSuperview()
                    }
                }
                
                uiView.addGestureRecognizer(pdfDrawingGestureRecognizer)
                pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
                pdfDrawer.drawingTool = options
                pdfDrawer.color = color.uiColor()
            } else {
                print("since both can edit and edit sign are true , which should not be the case , MAIN PAGE ACTIVE")
                for recog in uiView.gestureRecognizers! {
                    uiView.removeGestureRecognizer(recog)
                }
                uiView.addSubview(pdfThumbnailView)
            }
            
        } else {
            if canEditSignature {
                print("sign will get active")
            } else {
                print("remove everything and add main page as active")
                for recog in uiView.gestureRecognizers! {
                    uiView.removeGestureRecognizer(recog)
                }
//                uiView.document = PDFDocument(url: URL(string: self.fileURL)!)
            }
        }
        
        // signature part
        if image != nil {
            print("😁 received image")            
            pdfPanGestureRecognizer.panDelegate = pdfDrawer
            
            if !canEdit  {
                if canEditSignature {
                    print("adding image pan gesture")
                    print(pdfDrawer.calledOnce)
                    
                    if !pdfDrawer.calledOnce {
                        let page = uiView.currentPage!
                        let pageBounds = page.bounds(for: .cropBox)
                        let imageBounds = CGRect(x: 100, y: 100, width: 300, height: 300)
                        let imageStamp = ImageStampAnnotation(with: image, forBounds: imageBounds, withProperties: nil)

//                         so that signatures isnt duplicated later on
                        
                        print(page.annotations)
                        
                        for anno in page.annotations {
                            if anno.isKind(of: ImageStampAnnotation.self) {
                                page.removeAnnotation(anno)
                            }
                        }
                        
                        for view in uiView.subviews {
                            if view.isKind(of: PDFThumbnailView.self) {
                                view.removeFromSuperview()
                            }
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
//                    uiView.document = PDFDocument(url: URL(string: self.fileURL)!)
                }
            } else {
                print("CAN EDIT ON")
            }
            
            if alreadyAdded {
                let page = uiView.currentPage!
                page.removeAnnotation(page.annotations.last!)
                let pageBounds = page.bounds(for: .cropBox)
                let imageBounds = CGRect(x: 100, y: 100, width: 300, height: 300)
                let imageStamp = ImageStampAnnotation(with: image, forBounds: imageBounds, withProperties: nil)
                page.addAnnotation(imageStamp)
                uiView.addGestureRecognizer(pdfPanGestureRecognizer)
            }
            
        } else {
            print("no image")
        }
        
    }
    
}
