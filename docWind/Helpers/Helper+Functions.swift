//
//  Helper+Functions.swift
//  docWind
//
//  Created by Sarvad Shetty on 17/12/2020.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import UIKit


func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage? {

    // Setup the font specific variables
    let textColor = UIColor.black
    let textFont = UIFont.systemFont(ofSize: 15)

    // Setup the image context using the passed image
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

    // Setup the font attributes that will be later used to dictate how the text should be drawn
    let textFontAttributes = [
        NSAttributedString.Key.font: textFont,
        NSAttributedString.Key.foregroundColor: textColor,
    ]

    // Put the image into a rectangle as large as the original image
    inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))

    // Create a point within the space that is as bit as the image
    var rect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)

    // Draw the text into an image
    drawText.draw(in: rect, withAttributes: textFontAttributes)

    // Create a new image out of the images we have created
    var newImage = UIGraphicsGetImageFromCurrentImageContext()

    // End the context now that we have the image we need
    UIGraphicsEndImageContext()

    //Pass the image back up to the caller
    return newImage

}
