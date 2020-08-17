//
//  SlideOverCardView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/9/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SlideOverCardView: View {
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.middle
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
//    @Binding var drawings: [Drawing]
//    @Binding var canEdit: Bool
    
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return
            VStack {
                Handle()
                HStack {
                    Text("Options")
                        .padding()
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("Pencil Width")
                    Stepper("\(self.lineWidth, specifier: "%.2f")", value: self.$lineWidth, in: 1.0...15.0)
                }
                    .settingsBackground()
                VStack(alignment: .leading) {
                    Text("Change color")
                    ColorRow(selectedColor: $color)
                }.settingsBackground()

                Spacer()
            }
//            .frame( height: UIScreen.main.bounds.height)
                .frame(width: UIScreen.main.bounds.width)
                .background(Color(.systemBackground))
        .cornerRadius(10.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
                .offset(y: self.position.rawValue + self.dragState.translation.height)
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position.rawValue + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        let closestPosition: CardPosition
        
        if cardTopEdgeLocation <= CardPosition.middle.rawValue {
            positionAbove = .top
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }
        
        if (cardTopEdgeLocation - positionAbove.rawValue) < (positionBelow.rawValue - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }
        
        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
}

