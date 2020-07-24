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
    case intro, tappedDirec, tappedPdf, createdDirec, createPdf, settingsTapped
}

// Enum for activeSheetvar in PDFDetailView
enum PDFDetailActiveView {
    case shareSheet, toolBox, signature, ocrPage
}

// enum for active sheet #2
enum ActiveOdfMainViewSheet {
    case scannerView, pdfView
}

// enum for alert sheet
enum ActiveAlertSheet {
    case notice, delete, error, noPurchase
}

// enum for active sheet in carousel view
enum ActiveCarouselViewSheet {
    case shareView, fillView, ocrView
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

// Helper enums for SlideOverCardView
enum CardPosition: CGFloat {
    case top = 100
    case middle = 500
    case bottom = 600
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

// Helper enums for IAP
enum IAPProduct: String {
    case nonConsumable = "com.sarvadShetty.docWind.docWindPlusConsumable"
}

// active sheet for settings

enum SettingActiveSheet {
    case appIcon, docSub, mailFeature, mailBug, shareSheet
}
