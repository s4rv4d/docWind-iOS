//
//  ImagePanGestureRecognizer.swift
//  docWind
//
//  Created by Sarvad shetty on 7/16/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import UIKit

protocol ImagePanGestureRecognizerDelegate: class {
    func gestureRecognizerBeganIPG(_ location: CGPoint)
    func gestureRecognizerMovedIPG(_ location: CGPoint)
    func gestureRecognizerEndedIPG(_ location: CGPoint)
}

class ImagePanGestureRecognizer: UIPanGestureRecognizer {
    weak var panDelegate: ImagePanGestureRecognizerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, let numberOfTouches = event.allTouches?.count, numberOfTouches == 1 {
            state = .began
            let location = touch.location(in: self.view)
            panDelegate?.gestureRecognizerBeganIPG(location)
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .changed
        
        guard let location = touches.first?.location(in: self.view) else { return }
        panDelegate?.gestureRecognizerMovedIPG(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let location = touches.first?.location(in: self.view) else {
            state = .ended
            return }
        panDelegate?.gestureRecognizerEndedIPG(location)
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
}
