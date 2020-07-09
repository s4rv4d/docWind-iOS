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
    @Binding var images: [UIImage]
    var pageId: Int
    @State var currentDrawing: Drawing = Drawing()
    @State var drawings: [Drawing] = [Drawing]()
    @State private var color: Color = Color.black
    @State private var lineWidth: CGFloat = 3.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: self.images[self.pageId])
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
//                Slider(value: self.$lineWidth, in: 1.0...15.0, step: 1.0)
                
                VStack(alignment: .leading) {
                    SlideOverCardView(color: self.$color, lineWidth: self.$lineWidth)
                }

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
}

