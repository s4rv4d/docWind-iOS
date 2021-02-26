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
    case intro, tappedDirec, tappedPdf, createdDirec, createPdf, settingsTapped, editPdf, importDoc
}

extension ActiveContentViewSheet: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }
}

enum ActiveSheetForDetails {
    case shareSheet(url: String), editSheet(images: [UIImage], url: String, item: ItemModel), compressView
}

extension ActiveSheetForDetails: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }
}

// Enum for activeSheetvar in PDFDetailView
enum PDFDetailActiveView {
    case shareSheet, toolBox, signature, ocrPage(images: [UIImage]), editPage, subView
}

extension PDFDetailActiveView: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }
}

// enum for active sheet #1&2
enum ActiveOdfMainViewSheet {
    case scannerView, pdfView, photoLibrary, subView, imageEdit
}

extension ActiveOdfMainViewSheet: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }
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
    case appIcon, docSub, mailFeature, mailBug, shareSheet, dependency, UIUpdate
}

extension SettingActiveSheet: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(Self.self)
    }
}

enum ViewSide {
    case Left, Right, Top, Bottom
}

// different edit types ref for saving and editted doc
enum EditType {
    case rename
    case iconColor
    case newImagesAdded
    case compress
}


// enum to handle SF symbols
enum SFSymbol: String, View {
    case close = "xmark"
    case share = "square.and.arrow.up"
    case camera = "camera"
    case cameraRotateFill = "camera.rotate.fill"
    case magnifyingGlass = "magnifyingglass"
    case multiplyCircleFill = "multiply.circle.fill"
    case docFill = "doc.fill"
    case folderFill = "folder.fill"
    case pencil = "pencil"
    case pencilCircle = "pencil.circle"
    case trash = "trash"
    case chevronRight = "chevron.right"
    case plus = "plus"
    case gear = "gear"
    case rec3Offgrid = "rectangle.3.offgrid"
    case recGrid1x2 = "rectangle.grid.1x2"
    case textQuote = "text.quote"
    case scribble = "scribble"
    case textFormat = "textformat"
    case signature = "signature"
    case starFill = "star.fill"
    case crop = "crop"
    case sliderHorizontal3 = "slider.horizontal.3"
    case cameraFilters = "camera.filters"
    case docAppend = "doc.append"
    case chevronLeft = "chevron.left"
    case rotateLeft = "rotate.left"
    case rotateRight = "rotate.right"
    case xCircle = "x.circle"
    case checkmarkSealFill = "checkmark.seal.fill"
    case checkmarkCircle = "checkmark.circle"
    case exclamationMarkCircle = "exclamationmark.circle"
    case boltFill = "bolt.fill"
    case boltSlashFill = "bolt.slash.fill"
    case goForward = "goforward"
    case lockRectangleStackFill = "lock.rectangle.stack.fill"
    
    var body: some View {
        Image(systemName: rawValue)
    }
}
