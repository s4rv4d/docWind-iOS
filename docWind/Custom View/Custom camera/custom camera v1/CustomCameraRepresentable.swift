//
//  CustomCameraRepresentable.swift
//  Photostat
//
//  Created by Sarvad shetty on 10/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import AVFoundation
import MetalKit


struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    // MARK: - @Binding variables
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    @Binding var filterIndex: Int
    
    // MARK: - Life cycle
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.mainDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        
        cameraViewController.filterIndex = filterIndex
        
        if self.didTapCapture {
            cameraViewController.didTapRecord()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, CustomCameraDelegate {
        
        let parent: CustomCameraRepresentable
        
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func sendDataBack(uiimage: UIImage) {
            DispatchQueue.main.async {
                self.parent.image = uiimage.resizeImageUsingVImage(size: CGSize(width: 600, height: 900))!
//                self.parent.image = textToImage(drawText: "Scanned by PhotoStat", inImage: uiimage.resizeImageUsingVImage(size: CGSize(width: 600, height: 900))!, atPoint: CGPoint(x: 10, y: 10))!
                self.parent.didTapCapture = false
            }
        }
    }
}
