//
//  Helper+Extensions.swift
//  docWind
//
//  Created by Sarvad shetty on 7/5/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    func settingsBackground() -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground)))
            .padding(.bottom, 6)
//            .padding(.horizontal)
    }
}


extension UIImage {

    class func imageWithWatermark(image1: UIImage, image2: UIImage) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height)
        UIGraphicsBeginImageContextWithOptions(image1.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.white.cgColor)
        context!.fill(rect)
        
        image1.draw(in: CGRect(x: 0.0, y: 0.0, width: image1.size.width, height: image1.size.height))
        image2.draw(in: CGRect(x: 50, y: 200, width: ((image1.size.width/100) * 402), height: ((image1.size.height/100) * 3)))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
