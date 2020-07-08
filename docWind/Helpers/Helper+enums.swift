//
//  Helper+enums.swift
//  docWind
//
//  Created by Sarvad shetty on 7/4/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import SwiftUI

// Enum for differentiating item type
enum DWItemType: String {
    case directory
    case pdfFile
}

// Enum for activesheet
enum ActiveContentViewSheet {
    case intro, tappedDirec, tappedPdf, createdDirec, createPdf
}

// enum for active sheet #2
enum ActiveOdfMainViewSheet {
    case scannerView, pdfView
}

// Enum for folder icon colors
enum FolderIconColor: String {
    case blue
    case red
    case green
    case yellow
    case pink
}

enum FeedbackManager {
    static func mediumFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
