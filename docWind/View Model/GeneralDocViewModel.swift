//
//  GeneralDocViewModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/5/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation

class GeneralDocViewModel {
    
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
