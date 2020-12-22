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
                let img = image.resizeImageUsingVImage(size: CGSize(width: 596, height: 842))!
                
                
                let bytes = img.jpegData(compressionQuality: 0.8)!
                
                print("page dimensions \(image.size.width) by \(image.size.height) - JPEG size \(bytes.count)")
                
                let editImage = UIImage(data: bytes)!
                
                // watermark
                let item = MediaItem(image: editImage)
                                                    
                let testStr = "Scanned by DocWind"
                let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15) ]
                let attrStr = NSAttributedString(string: testStr, attributes: attributes)
                        
                let secondElement = MediaElement(text: attrStr)
                secondElement.frame = CGRect(x: 10, y: item.size.height - 50, width: item.size.width, height: item.size.height)
                        
                item.add(elements: [secondElement])
                        
                let mediaProcessor = MediaProcessor()
                mediaProcessor.processElements(item: item) {  (result, error) in
                    
                    let editableImage = result.image!
                    let editBytes = editableImage.jpegData(compressionQuality: 0.8)!
                    
                    DispatchQueue.main.async {
                        if self.uiImages.wrappedValue.count == 0 {
                            
                            self.uiImages.wrappedValue = [editImage]
                            self.uiImagesWithWatermarks.wrappedValue = [UIImage(data: editBytes)!]
                        } else {
                            self.uiImages.wrappedValue.append(editImage)
                            self.uiImagesWithWatermarks.wrappedValue.append(UIImage(data: editBytes)!)
                        }
                    }

                }
            }
            
            DispatchQueue.main.async {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
