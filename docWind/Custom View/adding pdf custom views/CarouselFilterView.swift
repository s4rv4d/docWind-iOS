//
//  CarouselFilterView.swift
//  docWind
//
//  Created by Sarvad Shetty on 03/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CarouselImageFilter: Identifiable {
    
    var id: String {
        filter.rawValue + String(image.hashValue)
    }
    
    var filter: ImageFilter
    var image: CPImage
    
    var filteredImage: CPImage {
        return filter.performFilter2(with: image)
    }
}

struct CarouselFilterView: View {
    
    let image: UIImage
    @Binding var filteredImage: CPImage
    
    fileprivate var imageFilters: [CarouselImageFilter] {
        return ImageFilter.allCases.map { CarouselImageFilter(filter: $0, image: image) }
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(imageFilters) { imageFilter in
                        VStack {
                                ZStack {
                                    Image(cpImage: imageFilter.filteredImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                }
                                
                                Text(imageFilter.filter.rawValue)
                                    .font(.subheadline)
                            }

                            .padding(.leading, 16)
                            .padding(.trailing, self.imageFilters.last!.filter == imageFilter.filter ? 16 : 0)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    let fil = ImageFilterObservable(image: imageFilter.image, filter: imageFilter.filter)
                                    fil.giveFilterImage { (image) in
                                        self.filteredImage = image
                                    }

                                }
                            }
                    }
                }
                .frame(height: 140)
            }
        }
    }

    private func addWatermark() {
        let mediaItem = MediaItem(image: filteredImage)
        
        /// text
        let testStr = "Scanned by DocWind"
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15) ]
        let attrStr = NSAttributedString(string: testStr, attributes: attributes)
        
        let secondElement = MediaElement(text: attrStr)
        secondElement.frame = CGRect(x: 10, y: mediaItem.size.height - 50, width: mediaItem.size.width, height: mediaItem.size.height)
        
        mediaItem.add(elements: [secondElement])
        
        let mediaProcessor = MediaProcessor()
        mediaProcessor.processElements(item: mediaItem) { [self] (result, error) in
            filteredImage = result.image!
        }
    }
}

extension CarouselFilterView: Equatable {

    static func == (lhs: CarouselFilterView, rhs: CarouselFilterView) -> Bool {
        return lhs.image == rhs.image
    }
}


struct ImageFilterView: View {
    
    @ObservedObject var observableImageFilter: ImageFilterObservable
    
    var body: some View {
        VStack {
            ZStack {
                Image(cpImage: observableImageFilter.filteredImage != nil ? observableImageFilter.filteredImage! : observableImageFilter.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .cornerRadius(8)
                    
                
                if observableImageFilter.filteredImage == nil {
                    ProgressView()
                }
            }
            
            Text(observableImageFilter.filter.rawValue)
                .font(.subheadline)
        }
        .onAppear(perform: self.observableImageFilter.filterImage)
    }
}

