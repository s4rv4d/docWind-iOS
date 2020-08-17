//
//  ImagePickerView.swift
//  docWind
//
//  Created by Sarvad shetty on 8/5/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    
    // MARK: - @Binding variables
    @Binding var pages: [UIImage]
    @Binding var pagesWithMark: [UIImage]
    
    // MARK: - Environment object
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - UIViewControllerRepresentable protocol functions
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, uiImages: $pages, uiImagesWithWatermarks: $pagesWithMark)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {}
    
    // MARK: - Coordinator
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        // MARK: - Properties
        var parent: ImagePickerView
        var uiImages: Binding<[UIImage]>
        var uiImagesWithWatermarks: Binding<[UIImage]>
        
        // MARK: - Init
        init(parent: ImagePickerView, uiImages: Binding<[UIImage]>, uiImagesWithWatermarks: Binding<[UIImage]>) {
            self.parent = parent
            self.uiImages = uiImages
            self.uiImagesWithWatermarks = uiImagesWithWatermarks
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let img = UIImage.resizeImageWithAspect(image: image, scaledToMaxWidth: 595, maxHeight: 842)!
                if self.uiImages.wrappedValue.count == 0 {
                    
                    self.uiImages.wrappedValue = [img]
                    self.uiImagesWithWatermarks.wrappedValue = [UIImage.imageWithWatermark(image1: img, image2: UIImage(named: "watermark")!)]
                } else {
                    self.uiImages.wrappedValue.append(img)
                    self.uiImagesWithWatermarks.wrappedValue.append(UIImage.imageWithWatermark(image1: img, image2: UIImage(named: "watermark")!))
                }
            }
            
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
