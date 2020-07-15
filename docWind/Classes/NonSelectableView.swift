//
//  NonSelectableView.swift
//  docWind
//
//  Created by Sarvad shetty on 7/14/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import UIKit
import PDFKit

class NonSelectablePDFView: PDFView {
    
    // Disable selection
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}
