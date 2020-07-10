//
//  Helper+Extensions.swift
//  docWind
//
//  Created by Sarvad shetty on 7/5/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import UIKit
import CoreImage

extension View {
    func settingsBackground() -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground)))
            .padding(.bottom, 6)
            .padding(.horizontal)
    }
    
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.renderedImage
    }
    
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)

        // locate far out of screen
//        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
//        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
//
//        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
//        controller.view.bounds = CGRect(origin: .zero, size: size)
//        controller.view.sizeToFit()
//
//        let image = controller.view.asImage()
//        controller.view.removeFromSuperview()
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)

        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        controller.view.backgroundColor = .clear
        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func uiColor() -> UIColor {
        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}


extension UIView {
    var renderedImage: UIImage {
        // rect of capure
        let rect = self.layer.bounds
        // create the context of bitmap
//        let rect = CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height)
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, 0.0)
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
//        draw(layer, in: <#T##CGContext#>)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        setNeedsDisplay()
        draw(layer, in: context)
//        context.fill(rect)
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
    
    func asImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
    // [!!] Uncomment to clip resulting image
                 rendererContext.cgContext.addPath(
                    UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath)
                rendererContext.cgContext.clip()
                rendererContext.cgContext.fill(bounds)
//                layer.render(in: rendererContext as! CGContext)
            }
        }
}
