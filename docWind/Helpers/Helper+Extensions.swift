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
import PDFKit

extension View {
    
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
    
    func settingsBackground() -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground)))
            .padding(.bottom, 6)
            .padding(.horizontal)
    }
    
    func settingsBackgroundButtons(color: Color) -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.4)))
            .padding(.bottom, 6)
//            .padding(.horizontal)
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
    
    func checkCondition(_ val:(Any) -> Void) -> some View {
        return self
    }
    
    func debugPrint(_ value: Any) -> some View {
            #if DEBUG
            print(value)
            #endif
            return self
        }
    
    func debug(_ value: Any, ex:@escaping() -> Void) -> some View {
//        #if DEBUG
        if value as! Bool == true {
            ex()
        }
//        #endif
        return self
    }
    
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        modifier(HiddenModifier(isHidden: hidden, remove: remove))
    }
    
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
    
    func keyboardSensible(_ offsetValue: Binding<CGFloat>) -> some View {

      return self
          .padding(.bottom, offsetValue.wrappedValue)
          .animation(.spring())
          .onAppear {
          NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in

              let keyWindow = UIApplication.shared.connectedScenes
                  .filter({$0.activationState == .foregroundActive})
                  .map({$0 as? UIWindowScene})
                  .compactMap({$0})
                  .first?.windows
                  .filter({$0.isKeyWindow}).first

              let bottom = keyWindow?.safeAreaInsets.bottom ?? 0

              let value = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
              let height = value.height

              offsetValue.wrappedValue = (height + 50) - bottom
          }

          NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
              offsetValue.wrappedValue = 0
          }
      }
    }
}


extension UIImage {

    class func imageWithWatermark(image1: UIImage, image2: UIImage) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: image1.size.width, height: image1.size.height)
        UIGraphicsBeginImageContextWithOptions(image1.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context!.fill(rect)
        
        image1.draw(in: CGRect(x: 0.0, y: 0.0, width: image1.size.width, height: image1.size.height))
        image2.draw(in: CGRect(x: 10, y: (image1.size.height/100) * 95, width: ((image1.size.width/100) * 40), height: ((image1.size.height/100) * 3)))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func resize(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    class func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    func outline() -> UIImage? {

        UIGraphicsBeginImageContext(size)
//        let rect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 5)
        let rect = CGRect(x: 0, y: size.height, width: size.width, height:100)
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0)
        context?.setLineWidth(100)
        context?.stroke(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage

    }
    
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)
     //    func imageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
     //        let square = CGSize(width: size.width, height: min(size.width, size.height) + width * 2)
     //        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
     //        imageView.contentMode = .center
     //        imageView.image = self
     //        imageView.layer.borderWidth = width
     //        imageView.layer.borderColor = color.cgColor
//             UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
//             guard let context = UIGraphicsGetCurrentContext() else { return nil }
//             imageView.layer.render(in: context)
//             let result = UIGraphicsGetImageFromCurrentImageContext()
//             UIGraphicsEndImageContext()
//             return result
     //    }
     
//     func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
//
//         let border = CALayer()
//         border.backgroundColor = color
//
//         switch side {
//         case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
//         case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
//         case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
//         case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
//         }
//
//         layer.addSublayer(border)
//     }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) -> UIImage? {

        let imageView = UIImageView(image: self)
        return imageView.addBorder(toSide: side, withColor: color, andThickness: thickness)!
        
//        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        imageView.layer.render(in: context)
//        let result = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return result
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
        _ = self.layer.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, 0.0)

        let context: CGContext = UIGraphicsGetCurrentContext()!
        setNeedsDisplay()
        draw(layer, in: context)
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
    
    func asImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                 rendererContext.cgContext.addPath(
                    UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath)
                rendererContext.cgContext.clip()
                rendererContext.cgContext.fill(bounds)
            }
        }
    
    /// Attaches all sides of the receiver to its parent view
    func coverWholeSuperview(margin: CGFloat = 0.0) {
        let view = superview
        layoutAttachTop(to: view, margin: margin)
        layoutAttachBottom(to: view, margin: margin)
        layoutAttachLeading(to: view, margin: margin)
        layoutAttachTrailing(to: view, margin: margin)

    }

    /// Attaches the top of the current view to the given view's top if it's a superview of the current view
    /// or to it's bottom if it's not (assuming this is then a sibling view).
    @discardableResult
    func layoutAttachTop(to: UIView? = nil, margin: CGFloat = 0.0) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = view == superview
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .top : .bottom, multiplier: 1.0,
                                            constant: margin)
        superview?.addConstraint(constraint)

        return constraint
    }

    /// Attaches the bottom of the current view to the given view
    @discardableResult
    func layoutAttachBottom(to: UIView? = nil, margin: CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .bottom : .top, multiplier: 1.0,
                                            constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)

        return constraint
    }

    /// Attaches the leading edge of the current view to the given view
    @discardableResult
    func layoutAttachLeading(to: UIView? = nil, margin: CGFloat = 0.0) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .leading : .trailing, multiplier: 1.0,
                                            constant: margin)
        superview?.addConstraint(constraint)

        return constraint
    }

    /// Attaches the trailing edge of the current view to the given view
    @discardableResult
    func layoutAttachTrailing(to: UIView? = nil, margin: CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {

        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal,
                                            toItem: view, attribute: isSuperview ? .trailing : .leading, multiplier: 1.0,
                                            constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)

        return constraint
    }

    // For anchoring View
    struct AnchoredConstraints {
        var top, leading, bottom, trailing, width, height, centerX, centerY: NSLayoutConstraint?
    }

    @discardableResult
    func constraints(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero,
                centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil,
                centerXOffset: CGFloat = 0, centerYOffset: CGFloat = 0) -> AnchoredConstraints {

        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()

        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }

        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }

        if let centerX = centerX {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: centerX, constant: centerXOffset)
        }

        if let centerY = centerY {
            anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: centerY, constant: centerYOffset)
        }

        [anchoredConstraints.top, anchoredConstraints.leading, anchoredConstraints.bottom,
         anchoredConstraints.trailing, anchoredConstraints.width,
         anchoredConstraints.height, anchoredConstraints.centerX,
         anchoredConstraints.centerY].forEach { $0?.isActive = true }

        return anchoredConstraints
    }
    
         func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) -> UIImage?{
    
             let border = CALayer()
             border.backgroundColor = color
    
             switch side {
             case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
             case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
             case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
             case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
             }
    
             layer.addSublayer(border)
            
            return self.asImage()
         }
}

// MARK: - PDF stuff
extension PDFAnnotation {
    
    func contains(point: CGPoint) -> Bool {
        var hitPath: CGPath?
        print("point to test \(point)")
        if let path = self.paths?.first {
            hitPath = path.cgPath.copy(strokingWithWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        }
        return hitPath?.contains(point) ?? false
    }
}


extension CGRect{
    var center: CGPoint {
        return CGPoint( x: self.size.width/2.0,y: self.size.height/2.0)
    }
}
extension CGPoint{
    func vector(to p1:CGPoint) -> CGVector{
        return CGVector(dx: p1.x-self.x, dy: p1.y-self.y)
    }
}

extension UIBezierPath{
    func moveCenter(to:CGPoint) -> Self{
        let bound  = self.cgPath.boundingBox
        let center = bounds.center
        
        let zeroedTo = CGPoint(x: to.x-bound.origin.x, y: to.y-bound.origin.y)
        let vector = center.vector(to: zeroedTo)
        
        _ = offset(to: CGSize(width: vector.dx, height: vector.dy))
        return self
    }
    
    func offset(to offset:CGSize) -> Self{
        let t = CGAffineTransform(translationX: offset.width, y: offset.height)
        _ = applyCentered(transform: t)
        return self
    }
    
    func fit(into:CGRect) -> Self{
        let bounds = self.cgPath.boundingBox
        
        let sw     = into.size.width/bounds.width
        let sh     = into.size.height/bounds.height
        let factor = min(sw, max(sh, 0.0))
        
        return scale(x: factor, y: factor)
    }
    
    func scale(x:CGFloat, y:CGFloat) -> Self{
        let scale = CGAffineTransform(scaleX: x, y: y)
        _ = applyCentered(transform: scale)
        return self
    }
    
    
    func applyCentered(transform: @autoclosure () -> CGAffineTransform ) -> Self{
        let bound  = self.cgPath.boundingBox
        let center = CGPoint(x: bound.midX, y: bound.midY)
        var xform  = CGAffineTransform.identity
        
        xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        xform = xform.concatenating(transform())
        xform = xform.concatenating( CGAffineTransform(translationX: center.x, y: center.y))
        apply(xform)
        
        return self
    }
}

extension PDFPage {
    func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
        for annotation in self.annotations {
            if annotation.contains(point: at) {
                return annotation
            }
        }
        return nil
    }
}


extension PDFAnnotation: Comparable {
    // made for comparing annotations in pdf, with respect to their type
    public static func < (lhs: PDFAnnotation, rhs: PDFAnnotation) -> Bool {
        false
    }
    
    
    public static func == (lhs: PDFAnnotation, rhs: PDFAnnotation) -> Bool {
        return (lhs.type == rhs.type && lhs.bounds == rhs.bounds)
    }
}

extension Binding {
    func didSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: {
                return self.wrappedValue
            },
            set: {
                self.wrappedValue = $0
                execute($0)
            }
        )
    }
}


extension String {
    // Modified from the DragonCherry extension - https://github.com/DragonCherry/VersionCompare
    private func compare(toVersion targetVersion: String) -> ComparisonResult {
        let versionDelimiter = "."
        var result: ComparisonResult = .orderedSame
        var versionComponents = components(separatedBy: versionDelimiter)
        var targetComponents = targetVersion.components(separatedBy: versionDelimiter)

        while versionComponents.count < targetComponents.count {
            versionComponents.append("0")
        }

        while targetComponents.count < versionComponents.count {
            targetComponents.append("0")
        }

        for (version, target) in zip(versionComponents, targetComponents) {
            result = version.compare(target, options: .numeric)
            if result != .orderedSame {
                break
            }
        }

        return result
    }

    func isVersion(equalTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedSame }

    func isVersion(greaterThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedDescending }

    func isVersion(greaterThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedAscending }

    func isVersion(lessThan targetVersion: String) -> Bool { return compare(toVersion: targetVersion) == .orderedAscending }

    func isVersion(lessThanOrEqualTo targetVersion: String) -> Bool { return compare(toVersion: targetVersion) != .orderedDescending }

    static func ==(lhs: String, rhs: String) -> Bool { lhs.compare(toVersion: rhs) == .orderedSame }

    static func <(lhs: String, rhs: String) -> Bool { lhs.compare(toVersion: rhs) == .orderedAscending }

    static func <=(lhs: String, rhs: String) -> Bool { lhs.compare(toVersion: rhs) != .orderedDescending }

    static func >(lhs: String, rhs: String) -> Bool { lhs.compare(toVersion: rhs) == .orderedDescending }

    static func >=(lhs: String, rhs: String) -> Bool { lhs.compare(toVersion: rhs) != .orderedAscending }
}

