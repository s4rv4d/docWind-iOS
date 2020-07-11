//
//  DrawOnImageView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/9/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct DrawOnImageView: View {
    
    // MARK: - Properties
    @Binding var mainImages: [UIImage]
    @Binding var imagesWithoutWater: [UIImage]
    @Binding var imageWithWater: [UIImage]
    var pageId: Int
    var image: UIImage
    @State var currentDrawing: Drawing = Drawing()
    @State var drawings: [Drawing] = [Drawing]()
    @State private var color: Color = Color(hex: "#000000")
    @State private var lineWidth: CGFloat = 3.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: self.image)
                .resizable()
                    .aspectRatio(contentMode: .fill)
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
                
                VStack(alignment: .leading) {
                    SlideOverCardView(color: self.$color, lineWidth: self.$lineWidth, drawings: self.$drawings)
                }
                
                VStack {
                    HStack{
                        Button("Cancel") {
                            print("dismising...")
                            self.presentationMode.wrappedValue.dismiss()
                        }.settingsBackground()
                        Spacer()
                        Button("Save") {
                            print("saving...")
                            
                            let image2 = self.drawLineOnImage(origin: geometry.frame(in: .global).origin, size: geometry.size, image: self.imagesWithoutWater[self.pageId], points: self.drawings, color: self.color, lineWidth: self.lineWidth).resize(toWidth: 250)!
                            self.imagesWithoutWater[self.pageId] = image2
                            
                            let image3 = self.drawLineOnImage(origin: geometry.frame(in: .global).origin, size: geometry.size, image: self.imageWithWater[self.pageId], points: self.drawings, color: self.color, lineWidth: self.lineWidth).resize(toWidth: 250)!
                            self.imageWithWater[self.pageId] = image3
                            
                            self.presentationMode.wrappedValue.dismiss()
                        }.settingsBackground()
                    }
                    Spacer()
                }.padding()

            }
        }
    }

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
    
    func drawLineOnImage(origin: CGPoint, size: CGSize, image: UIImage, points: [Drawing], color: Color, lineWidth: CGFloat) -> UIImage {
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(size)
    // draw original image into the context
    image.draw(in: CGRect(origin: origin, size: size))
    // get the context for CoreGraphics
    let context = UIGraphicsGetCurrentContext()

    // set stroking width and color of the context
        context!.setLineWidth(lineWidth)
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
    // apply the stroke to the context
    context!.strokePath()
    // get the image from the graphics context
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    // end the graphics context
    UIGraphicsEndImageContext()
        return resultImage!
    }
}

