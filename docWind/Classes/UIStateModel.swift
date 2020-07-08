//
//  UIStateModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/8/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation


public class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}
