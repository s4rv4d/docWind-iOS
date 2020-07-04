//
//  DocViewModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/2/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation

class MainDocViewModel {
    
    // MARK: - Properties
    let directory: DirecModel
    
    // MARK: - Init
    init(directory: DirecModel) {
        self.directory = directory
    }
    
    var createdDate: Date {
        self.directory.wrappedCreated
    }
    
    var direcName: String {
        self.directory.wrappedName
    }
    
    var direcContents: [ItemModel] {
        self.directory.fileArray
    }
}
