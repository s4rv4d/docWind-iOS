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
}

struct CarouselFilterView: View {
    
    let image: UIImage?
    @Binding var filteredImage: CPImage
    
    fileprivate var imageFilters: [CarouselImageFilter] {
        print("called")

        guard let image = self.image else { return [] }
        
        return ImageFilter.allCases.map { CarouselImageFilter(filter: $0, image: image) }
    }
    #warning("need to fix this")
    var body: some View {
        VStack {
            if image != nil {
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(imageFilters) { imageFilter in
                            ImageFilterView(observableImageFilter: ImageFilterObservable(image: imageFilter.image, filter: imageFilter.filter), filteredImage: $filteredImage)
                                .padding(.leading, 16)
                                .padding(.trailing, self.imageFilters.last!.filter == imageFilter.filter ? 16 : 0)
//                                .onTapGesture {
//                                    let fil = ImageFilterObservable(image: imageFilter.image, filter: imageFilter.filter)
//                                    fil.giveFilterImage { (image) in
//                                        self.filteredImage = image
//                                    }
//                                }
                        }
                    }
                    .frame(height: 140)
                    .debugPrint("here")
                }
            }
        }
    }
    
    func filterView( observableImageFilter: ImageFilterObservable) -> some View {
        
        let image = observableImageFilter.giveImage2()
        
        return VStack {
                ZStack {
                    Image(cpImage: image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .cornerRadius(8)
                        
                    
//                    if observableImageFilter.filteredImage == nil {
//                        ProgressView()
//                    }
                }
                
                Text(observableImageFilter.filter.rawValue)
                    .font(.subheadline)
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
    @Binding var filteredImage: CPImage
    
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
        .onReceive(observableImageFilter.$filteredImage, perform: observableImageFilter.filterImage)
//        .onAppear(perform: self.observableImageFilter.filterImage)
        .onTapGesture(perform: handleOnTap)
    }
    #warning("test on testflight")
    private func handleOnTap() {
        guard let filteredImage = observableImageFilter.filteredImage else {
            return
        }
        self.filteredImage = filteredImage
    }
}

//.onReceive(observableImageFilter.$filteredImage, perform: observableImageFilter.filterImage)
