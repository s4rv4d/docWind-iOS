//
//  ImageFilterObservable.swift
//  docWind
//
//  Created by Sarvad Shetty on 03/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

class ImageFilterObservable: ObservableObject {
    
    @Published var filteredImage: UIImage? = nil

    let image: UIImage
    let filter: ImageFilter
    
    init(image: CPImage, filter: ImageFilter) {
        self.image = image
        self.filter = filter
    }
    
    func filterImage() {
        self.filter.performFilter(with: self.image) { fillImage in
            DispatchQueue.main.async {
                self.filteredImage = fillImage
            }
        }
    }
    
    func giveFilterImage(completion:@escaping (UIImage) -> ()) {
        self.filter.performFilter(with: self.image) { fillImage in
            DispatchQueue.main.async {
                self.filteredImage = fillImage
                completion(fillImage)
            }
        }
    }
    
    func giveImage2() -> UIImage? {
        var image:UIImage?
        self.filter.performFilter(with: self.image) { fillImage in
            image = fillImage
        }
        
        return image 
    }
}
