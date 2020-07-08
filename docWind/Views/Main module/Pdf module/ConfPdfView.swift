//
//  ConfPdfView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/7/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct ConfPdfView: View {
    
    // MARK: - @Binding properties
    @Binding var pages: [UIImage]
    
    
    
    var body: some View {
        VStack {
            // need to implament custom carousel
//            Image(uiImage: pages[0])
//            .resizable()
//                .aspectRatio(contentMode: .fill)
//            .padding()
//                .padding(.horizontal)
//            SnapCarouselView(images: [], title: "")
            EmptyView()
        }
    }
}

