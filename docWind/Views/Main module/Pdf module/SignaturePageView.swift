//
//  SignaturePageView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/16/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SignaturePageView: View {
    
    @State var currentDrawing: Drawing = Drawing()
    @State var drawings: [Drawing] = [Drawing]()
    @State private var color: Color = Color(hex: "#000000")
    @State private var lineWidth: CGFloat = 3.0
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
//                Image(uiImage: self.image)
                Color.white
                    .gesture(
                        DragGesture(minimumDistance: 0.1)
                            .onChanged({ (value) in
                                let currentPoint = value.location
                                if currentPoint.y >= 0
                                    && currentPoint.y < geometry.size.height {
                                    self.currentDrawing.points.append(currentPoint)
                                }
                            })
                            .onEnded({ (value) in
                                self.drawings.append(self.currentDrawing)
                                self.currentDrawing = Drawing()
                            })
                    )
                
                Path { path in
                    for drawing in self.drawings {
                        self.add(drawing: drawing, toPath: &path)
                    }
                    self.add(drawing: self.currentDrawing, toPath: &path)
                }.stroke(self.color, lineWidth: self.lineWidth)
                
                VStack {
                    CustomHeaderView(title: "Signature", action: {
                        let image = self.captureLine(origin: geometry.frame(in: .global).origin, size: geometry.size, points: self.drawings, image: self.drawRectangle())
                        self.image = image
                        self.presentationMode.wrappedValue.dismiss()
                        
                        }).padding()
                        .background(Color.black)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Functions
    private func add(drawing: Drawing, toPath path: inout Path) {
        let points = drawing.points
        if points.count > 1 {
            for i in 0..<points.count-1 {
                let current = points[i]
                let next = points[i+1]
                path.move(to: current)
                path.addLine(to: next)
            }
        }
    }
    
    func drawRectangle() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))

        let img = renderer.image { ctx in
            // awesome drawing code
            let rectangle = CGRect(x: 0, y: 0, width: 300, height: 300)

            ctx.cgContext.setFillColor(UIColor.green.cgColor)
//            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
//            ctx.cgContext.setLineWidth(10)

            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
        }
        return img
    }
    
    func captureLine(origin: CGPoint, size: CGSize, points: [Drawing], image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
//        UIImage().draw(in: CGRect(origin: origin, size: size))
//        image.draw(in: CGRect(origin: origin, size: size))
        
        let context = UIGraphicsGetCurrentContext()
        let color = self.color
        context!.setLineWidth(self.lineWidth)
        context!.setStrokeColor(color.uiColor().cgColor)
        
        for drawing in self.drawings {
            let points = drawing.points
            if points.count > 1 {
                for i in 0..<points.count-1 {
                    let current = points[i]
                    let next = points[i+1]
                    context!.move(to: current)
                    context!.addLine(to: next)
                }
            }
            
        }
        
        context!.strokePath()
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
    private func saveTapped() {
        
    }
    
}

