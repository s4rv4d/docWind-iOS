//
//  PDFDrawer.swift
//  docWind
//
//  Created by Sarvad shetty on 7/14/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import PDFKit

enum DrawingTool: Int {
    case eraser = 0
    case pencil = 1
    case pen = 2
    case highlighter = 3
    case none = 69
    
    var width: CGFloat {
        switch self {
        case .pencil:
            return 0.5
        case .pen:
            return 1
        case .highlighter:
            return 15
        default:
            return 0
        }
    }
    
    var alpha: CGFloat {
        switch self {
        case .highlighter:
            return 0.3 //0,5
        default:
            return 1
        }
    }
}

class PDFDrawer {
    weak var pdfView: PDFView!
    var path: UIBezierPath?
    private var currentAnnotation : DrawingAnnotation?
    private var currentlySelectedAnnotation: ImageStampAnnotation?
    private var currentPage: PDFPage?
    var color = UIColor.red // default color is red
    var drawingTool = DrawingTool.pen
    var calledOnce: Bool = false
    
    init() {
        print("PDF Drawer being called! 🛠")
    }
}

extension PDFDrawer: DrawingGestureRecognizerDelegate {
    func gestureRecognizerBegan(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
        path = UIBezierPath()
        path?.move(to: convertedPoint)
    }
    
    func gestureRecognizerMoved(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        if drawingTool == .eraser {
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        drawAnnotation(onPage: page)
    }
    
    func gestureRecognizerEnded(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        // Erasing
        if drawingTool == .eraser {
            print("converted point is: \(convertedPoint)")
            removeAnnotationAtPoint(point: convertedPoint, page: page)
            return
        }
        
        // Drawing
        guard let _ = currentAnnotation else { return }
        
        path?.addLine(to: convertedPoint)
        path?.move(to: convertedPoint)
        
        // Final annotation
        page.removeAnnotation(currentAnnotation!)
        _ = createFinalAnnotation(path: path!, page: page)
        currentAnnotation = nil
    }
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage) -> DrawingAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(drawingTool.alpha)
        annotation.border = border
        return annotation
    }
    
    private func drawAnnotation(onPage: PDFPage) {
        guard let path = path else { return }
        
        if currentAnnotation == nil {
            currentAnnotation = createAnnotation(path: path, page: onPage)
        }
        
        currentAnnotation?.path = path
        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }
    
    private func createFinalAnnotation(path: UIBezierPath, page: PDFPage) -> PDFAnnotation {
        let border = PDFBorder()
        border.lineWidth = drawingTool.width
        
        let bounds = CGRect(x: path.bounds.origin.x - 5,
                            y: path.bounds.origin.y - 5,
                            width: path.bounds.size.width + 10,
                            height: path.bounds.size.height + 10)
        let signingPathCentered = UIBezierPath()
        signingPathCentered.cgPath = path.cgPath
        _ = signingPathCentered.moveCenter(to: bounds.center)
        
        let annotation = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        annotation.color = color.withAlphaComponent(drawingTool.alpha)
        annotation.border = border
        annotation.add(signingPathCentered)
        page.addAnnotation(annotation)
                
        return annotation
    }
    
    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotation(at: point) {
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
        }
    }
    
    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
        onPage.removeAnnotation(annotation)
        onPage.addAnnotation(annotation)
    }
}

extension PDFDrawer: ImagePanGestureRecognizerDelegate {
    
    // MARK: - ImagePanGestureRecognizerDelegate
    func gestureRecognizerBeganIPG(_ location: CGPoint) {
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
        
        guard let annotation = page.annotation(at: convertedPoint) else {
            return
        }
        
        if annotation.isKind(of: ImageStampAnnotation.self) {
            currentlySelectedAnnotation = (annotation as! ImageStampAnnotation)
        }
    }
    
    func gestureRecognizerMovedIPG(_ location: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        
        guard let annotation = currentlySelectedAnnotation else { return}
        let initialBounds = annotation.bounds
        // Set the center of the annotation to the spot of our finger
        annotation.bounds = CGRect(x: convertedPoint.x - (initialBounds.width / 2), y: convertedPoint.y - (initialBounds.height / 2), width: initialBounds.width, height: initialBounds.height)
    }
    
    func gestureRecognizerEndedIPG(_ location: CGPoint) {
//        guard let page = currentPage else { return }
//        let convertedPoint = pdfView.convert(location, to: page)
//
//        guard let annotation = currentlySelectedAnnotation else { return}
//        let initialBounds = annotation.bounds
//        // Set the center of the annotation to the spot of our finger
//        annotation.bounds = CGRect(x: convertedPoint.x - (initialBounds.width / 2), y: convertedPoint.y - (initialBounds.height / 2), width: initialBounds.width, height: initialBounds.height)
//
//        _ = createFinalImageBounds(page: page, finalAnnoBound: annotation.bounds)
//
        currentlySelectedAnnotation = nil
    }
    
    private func createFinalImageBounds(page: PDFPage, finalAnnoBound: CGRect) -> PDFAnnotation {
        let imageBounds = CGRect(x: finalAnnoBound.midX, y: finalAnnoBound.midY, width: 200, height: 100)
        let imageStamp = ImageStampAnnotation(with: currentlySelectedAnnotation!.image, forBounds: imageBounds, withProperties: nil)
        
        for anno in page.annotations {
            if anno == imageStamp {
                page.removeAnnotation(anno)
            }
        }
        
        page.addAnnotation(imageStamp)
        return imageStamp
    }
    
}
