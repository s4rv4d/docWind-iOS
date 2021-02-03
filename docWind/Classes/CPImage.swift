//
//  CPImage.swift
//  docWind
//
//  Created by Sarvad Shetty on 03/02/2021.
//  Copyright © 2021 Sarvad shetty. All rights reserved.
//

import SwiftUI

#if os(iOS)
import UIKit
public typealias CPImage = UIImage
#elseif os(OSX)
import AppKit
public typealias CPImage = NSImage
#endif
