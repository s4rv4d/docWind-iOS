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
    @Binding var uiImages:[UIImage]
    @Binding var uiImagesWithWatermarks: [UIImage]
    @State var ac = false
    
    // MARK: - Properties
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(uiImages: $uiImages, uiImagesWithWatermarks: $uiImagesWithWatermarks, state: $ac)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScannerView>) {
        
        if ac {
            let acIndicator = UIActivityIndicatorView(style: .large)
            acIndicator.hidesWhenStopped = true
            acIndicator.center = uiViewController.view.center
            acIndicator.color = .cyan
            uiViewController.view.addSubview(acIndicator)
            uiViewController.view.bringSubviewToFront(acIndicator)
            acIndicator.startAnimating()
        }
        
    }
    
    // MARK: - Coordinator class
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        var uiImages: Binding<[UIImage]>
        var uiImagesWithWatermarks: Binding<[UIImage]>
        var state: Binding<Bool>
        
        init(uiImages: Binding<[UIImage]>, uiImagesWithWatermarks: Binding<[UIImage]>, state: Binding<Bool>) {
            self.uiImages = uiImages
            self.uiImagesWithWatermarks = uiImagesWithWatermarks
            self.state = state
        }
                
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Save TAPPED")
            var imgs = [UIImage]()
            var imgsWithWatermarks = [UIImage]()
            
            
            
            for pageIndex in 0 ..< scan.pageCount {
                autoreleasepool {
                    let image = UIImage.resizeImageWithAspect(image: scan.imageOfPage(at: pageIndex), scaledToMaxWidth: 595, maxHeight: 842)!
                    imgsWithWatermarks.append(UIImage.imageWithWatermark(image1: image, image2: UIImage(named: "watermark")!))
                    imgs.append(image)
                }
            }
            state.wrappedValue.toggle()
            
            // appending images based on image counts
            if self.uiImages.wrappedValue.count == 0 {
                self.uiImages.wrappedValue = imgs
                self.uiImagesWithWatermarks.wrappedValue = imgsWithWatermarks
            } else {
                self.uiImages.wrappedValue +=  imgs
                self.uiImagesWithWatermarks.wrappedValue += imgsWithWatermarks
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                controller.dismiss(animated: true, completion: nil)
            }
            
            
        }
        
        private func compressedImage(_ originalImage: UIImage) -> UIImage {
            guard let imageData = originalImage.jpegData(compressionQuality: 1),
                let reloadedImage = UIImage(data: imageData) else {
                    return originalImage
            }
            return reloadedImage
        }
        
    }

}

