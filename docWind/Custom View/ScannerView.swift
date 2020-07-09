//
//  ScannerView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/6/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import UIKit
import VisionKit
import Combine

struct ScannerView: UIViewControllerRepresentable {
    
    // MARK: - @Binding vars
    @Binding var recognizedText: String
    @Binding var uiImages:[UIImage]
    @Binding var uiImagesWithWatermarks: [UIImage]
    
    // MARK: - Properties
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(recognizedText: $recognizedText, uiImages: $uiImages, uiImagesWithWatermarks: $uiImagesWithWatermarks)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScannerView>) {
        
    }
    
    // MARK: - Coordinator class
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        var recognizedText: Binding<String>
        private let textRecognizer: TextRecognizer
        var uiImages: Binding<[UIImage]>
        var uiImagesWithWatermarks: Binding<[UIImage]>
        
        init(recognizedText: Binding<String>, uiImages: Binding<[UIImage]>, uiImagesWithWatermarks: Binding<[UIImage]>) {
            self.recognizedText = recognizedText
            textRecognizer = TextRecognizer(recognizedText: recognizedText)
            self.uiImages = uiImages
            self.uiImagesWithWatermarks = uiImagesWithWatermarks
        }
                
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Save TAPPED")
            #warning("MEMORY  MANAGEMENT")
//            var images = [CGImage]()
            var imgs = [UIImage]()
            var imgsWithWatermarks = [UIImage]()
            for pageIndex in 0 ..< scan.pageCount {
                #warning("rewrite this code into an efficient way use same array")
//                let image = scan.imageOfPage(at: pageIndex)
//                if let cgImage = image.cgImage {
//                    images.append(cgImage)
//                    imgs.append(image)
//                }
//                imgs.append(scan.imageOfPage(at: pageIndex))
                imgsWithWatermarks.append(UIImage.imageWithWatermark(image1: scan.imageOfPage(at: pageIndex), image2: UIImage(named: "watermark")!))
                imgs.append(scan.imageOfPage(at: pageIndex))
//                images.append(scan.imageOfPage(at: pageIndex).cgImage!
//                )
            }
            self.uiImages.wrappedValue = imgs
            self.uiImagesWithWatermarks.wrappedValue = imgsWithWatermarks
            //set binding vars for image and cgimage
//            textRecognizer.recognizeText(from: images)
            controller.dismiss(animated: true, completion: nil)
        }
        
    }

}

