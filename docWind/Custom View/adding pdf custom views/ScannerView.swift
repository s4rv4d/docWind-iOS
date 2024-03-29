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
import Throttler

struct ScannerView: UIViewControllerRepresentable {
    
    // MARK: - @Binding vars
    @Binding var uiImages:[UIImage]
    @Binding var sheetState: ActiveOdfMainViewSheet?
    @State var ac = false
    
    // MARK: - Properties
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(uiImages: $uiImages, state: $ac, sheetState: $sheetState)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScannerView>) {
        
        if ac {
            // activity indicator
            let acIndicator = UIActivityIndicatorView(style: .large)
            acIndicator.hidesWhenStopped = true
            acIndicator.center = uiViewController.view.center
            acIndicator.color = .systemBlue
            
            // black background view
            let blackView = UIView()
            blackView.frame = uiViewController.view.bounds
            blackView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            
            
            // message for users
            let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
            yourLabel.textColor = UIColor.white
            yourLabel.text = "This may take a minute, please wait :)"
            yourLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // presenting everything
            DispatchQueue.main.async {
                uiViewController.view.addSubview(acIndicator)
                uiViewController.view.addSubview(blackView)
                blackView.addSubview(yourLabel)
                NSLayoutConstraint.activate([
                    yourLabel.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
                    yourLabel.topAnchor.constraint(equalToSystemSpacingBelow: acIndicator.bottomAnchor, multiplier: 2)
                ])

                uiViewController.view.bringSubviewToFront(acIndicator)
                uiViewController.delegate = nil
                
                // start animating
                acIndicator.startAnimating()
            }
        }
        
    }
    
    // MARK: - Coordinator class
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        var uiImages: Binding<[UIImage]>
        var state: Binding<Bool>
        var sheetState: Binding<ActiveOdfMainViewSheet?>
        
        init(uiImages: Binding<[UIImage]>, state: Binding<Bool>, sheetState: Binding<ActiveOdfMainViewSheet?>) {
            self.uiImages = uiImages
            self.state = state
            self.sheetState = sheetState
        }
                
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Save TAPPED")
//            var imgs = [UIImage]()
                        
            Throttler.go {
                for pageIndex in 0 ..< scan.pageCount {
                    autoreleasepool {
                        let image = scan.imageOfPage(at: pageIndex)
                            .resizeImageUsingVImage(size: CGSize(width: 596, height: 842))!
                        
                        // compression part
                        let bytes = image.jpegData(compressionQuality: 1)!
                        
                        print("page dimensions \(image.size.width) by \(image.size.height) - JPEG size \(bytes.count)")
                        
                        let editImage = UIImage(data: bytes)!
                        self.uiImages.wrappedValue.append(editImage)
                    }
                }
                self.state.wrappedValue.toggle()
                
    //            self.uiImages.wrappedValue +=  imgs
                
    //            // appending images based on image counts
    //            if self.uiImages.wrappedValue.count == 0 {
    //                self.uiImages.wrappedValue = imgs
    //            } else {
    //                self.uiImages.wrappedValue +=  imgs
    //            }
                
                controller.dismiss(animated: true, completion: {
                    if self.uiImages.wrappedValue.count != 0 {
                        self.sheetState.wrappedValue = .imageEdit
                    } else {
                        self.sheetState.wrappedValue = nil
                    }
                })
            }
            
        }
        
        private func compressedImage(_ originalImage: UIImage) -> UIImage {
            guard let imageData = originalImage.jpegData(compressionQuality: 1),
                let reloadedImage = UIImage(data: imageData) else {
                    return originalImage
            }
            return reloadedImage
        }

        func getImage(image: UIImage, backgroundColor: UIColor)->UIImage?{

            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            backgroundColor.setFill()
            //UIRectFill(CGRect(origin: .zero, size: image.size))
            let rect = CGRect(origin: .zero, size: image.size)
            let path = UIBezierPath(arcCenter: CGPoint(x:rect.midX, y:rect.midY), radius: rect.midX, startAngle: 0, endAngle: 6.28319, clockwise: true)
            path.fill()
            image.draw(at: .zero)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        
    }

}

