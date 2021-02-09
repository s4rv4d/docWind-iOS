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
    @Binding var sheetState: ActiveOdfMainViewSheet?
    
    // MARK: - Environment object
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - UIViewControllerRepresentable protocol functions
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, uiImages: $pages, sheetState: $sheetState)
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
        var sheetState: Binding<ActiveOdfMainViewSheet?>
        
        // MARK: - Init
        init(parent: ImagePickerView, uiImages: Binding<[UIImage]>, sheetState: Binding<ActiveOdfMainViewSheet?>) {
            self.parent = parent
            self.uiImages = uiImages
            self.sheetState = sheetState
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let img = image.resizeImageUsingVImage(size: CGSize(width: 596, height: 842))!
                
                let bytes = img.jpegData(compressionQuality: 0.8)!
                
                print("page dimensions \(image.size.width) by \(image.size.height) - JPEG size \(bytes.count)")
                
                let editImage = UIImage(data: bytes)!
                
                DispatchQueue.main.async {
                    if self.uiImages.wrappedValue.count == 0 {
                        
                        self.uiImages.wrappedValue = [editImage]
                    } else {
                        self.uiImages.wrappedValue.append(editImage)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.parent.presentationMode.wrappedValue.dismiss()
                self.sheetState.wrappedValue = .imageEdit
            }
        }
    }
}
