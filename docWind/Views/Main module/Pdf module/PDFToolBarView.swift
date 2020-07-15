//
//  PDFToolBarView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/15/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct PDFToolBarView: View {
    
    // MARK: - @Binding variables
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    @Binding var options: DrawingTool
    
    var body: some View {
        VStack {
            Handle()
            HStack {
                Text("Options")
                    .padding()
                Spacer()
            }
//            VStack(alignment: .leading) {
//                Text("Pencil Width")
//                Stepper("\(self.lineWidth, specifier: "%.2f")", value: self.$lineWidth, in: 1.0...15.0)
//            }
//                .settingsBackground()
            VStack(alignment: .leading) {
                Text("Change color")
                ColorRow(selectedColor: $color)
            }.settingsBackground()
            Spacer()
            HStack {

                Button("eraser") {
                    self.options = .eraser
                }.settingsBackground()

                Button("highlighter") {
                    self.options = .highlighter
                }.settingsBackground()

                Button("pen") {
                    self.options = .pen
                }.settingsBackground()

                Button("pencil") {
                    self.options = .pencil
                }.settingsBackground()
            }
//                .padding()
        }
    }
}

