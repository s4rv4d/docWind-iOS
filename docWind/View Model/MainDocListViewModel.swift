//
//  MainDocListViewModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/3/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

final class MainDocListViewModel: ObservableObject {
 
    // MARK: - Properties
    @Published var contents: MainDocViewModel? = nil
    
    // MARK: - Init
    init() {
        self.fetchContent()
    }
    
    // MARK: - Methods
    func fetchContent() {
        // declare the moc(managed object context)
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //make a single object observation request
        let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
        fetchRequest.predicate = NSPredicate(format: "name == %@", "DocWind")
        
        do {
            let content = try moc.fetch(fetchRequest)

            if let docWindContent = content.first {
                self.contents = MainDocViewModel(directory: docWindContent)
            } else {
                print("❌ ERROR CONVERTING TO MainDocViewModel")
            }
        } catch {
            print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
        }
        
    }
    
    func addANewItem() {
        
    }
}
