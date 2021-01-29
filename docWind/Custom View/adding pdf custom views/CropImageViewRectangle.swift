//
//  CropImageViewRectangle.swift
//  docWind
//
//  Created by Sarvad Shetty on 29/01/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct CropImageViewRectangle: View {
    @Binding var currentPositionTopLeft: CGPoint
    @Binding var currentPositionTopRight: CGPoint
    @Binding var currentPositionBottomLeft: CGPoint
    @Binding var currentPositionBottomRight: CGPoint

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: self.currentPositionTopLeft)
                path.addLine(
                    to: .init(
                        x: self.currentPositionTopRight.x,
                        y: self.currentPositionTopRight.y
                    )
                )
                path.addLine(
                    to: .init(
                        x: self.currentPositionBottomRight.x,
                        y: self.currentPositionBottomRight.y
                    )
                )
                path.addLine(
                    to: .init(
                        x: self.currentPositionBottomLeft.x,
                        y: self.currentPositionBottomLeft.y
                    )
                )
                path.addLine(
                    to: .init(
                        x: self.currentPositionTopLeft.x,
                        y: self.currentPositionTopLeft.y
                    )
                )
            }
            .stroke(Color.blue, lineWidth: CGFloat(1))
        }
    }
}

struct CropImageViewRectangleCorner: View {
    @Binding var currentPosition: CGPoint
    @Binding var newPosition: CGPoint

    var displacementX: CGFloat
    var displacementY: CGFloat

    var body: some View {
        Circle().foregroundColor(Color.blue).frame(width: 24, height: 24)
        .offset(x: self.currentPosition.x, y: self.currentPosition.y)
        .gesture(DragGesture()
            .onChanged { value in
                self.currentPosition = CGPoint(x: value.translation.width + self.newPosition.x, y: value.translation.height + self.newPosition.y)
            }
            .onEnded { value in
                self.currentPosition = CGPoint(x: value.translation.width + self.newPosition.x, y: value.translation.height + self.newPosition.y)
                self.newPosition = self.currentPosition
            }
        )
        .opacity(0.5)
        .position(CGPoint(x: 0, y: 0))
        .onAppear() {
            if self.displacementX > 0 || self.displacementY > 0 {
                self.currentPosition = CGPoint(x: self.displacementX, y: self.displacementY)
                self.newPosition = self.currentPosition
            }
        }
    }
}
