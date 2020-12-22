//
//  CustomCameraPhotoView.swift
//  Photostat
//
//  Created by Sarvad shetty on 10/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CustomCameraPhotoView: View {
    
    // MARK: - @State View modifiers
    @State private var image: UIImage?
    @State private var showingCustomCamera = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        Text("Change later")
    }
}

struct CustomCameraPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCameraPhotoView()
    }
}
