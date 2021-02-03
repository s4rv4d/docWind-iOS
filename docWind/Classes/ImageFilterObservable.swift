//
//  ImageFilterObservable.swift
//  docWind
//
//  Created by Sarvad Shetty on 03/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import Combine

class ImageFilterObservable: ObservableObject {
    
    @Published var filteredImage: CPImage? = nil

    let image: CPImage
    let filter: ImageFilter
    
    init(image: CPImage, filter: ImageFilter) {
        self.image = image
        self.filter = filter
    }
    
    func filterImage() {
        self.filter.performFilter(with: self.image) {
            self.filteredImage = $0
        }
    }
}
