//
//  CarouselCardModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import UIKit

struct Carditem: Hashable, Identifiable{
    var id: Int
    var name: String = ""
    var image: UIImage
}
