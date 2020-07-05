//
//  GeneralDocListViewModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/5/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData

final class GeneralDocListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var contents: GeneralDocViewModel? = nil
    @Published var direcObject: DirecModel? = nil
    
    let direcName: String
    
    // MARK: - Init
    init(name: String) {
        self.direcName = name
        self.fetchContent()
    }
    
    // MARK: - Methods
    func fetchContent() {
        // declare the moc
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // make a single observation request
        let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
        fetchRequest.predicate = NSPredicate(format: "name == %@", direcName)
        
        do {
            let content = try moc.fetch(fetchRequest)
            
            if let genDocContent = content.first {
                self.contents = GeneralDocViewModel(directory: genDocContent)
                self.direcObject = genDocContent
            } else {
                print("❌ ERROR CONVERTING TO GeneralDocViewModel")
            }
        } catch {
            print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
        }
    }
    
    func addANewItem(itemName: String, iconName: String, itemType: String, locked:Bool) {
        // declare the moc(managed object context)
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //make a single object observation request
        let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
        fetchRequest.predicate = NSPredicate(format: "name == %@", direcName)
        
        do {
            let content = try moc.fetch(fetchRequest)

            if let genDocContent = content.first {
                self.contents = GeneralDocViewModel(directory: genDocContent)
                self.direcObject = genDocContent
                                
                // add new item
                let itemName = itemName
                let iconName = iconName
                let itemType = itemType
                let isLocked = locked
                
                let item = ItemModel(context: moc)
                item.itemName = itemName
                item.itemType = itemType
                item.iconName = iconName
                item.locked = NSNumber(booleanLiteral: isLocked)
                item.itemCreated = Date()
                item.origin = direcObject
                
                direcObject?.addToFiles(item)
                self.contents = GeneralDocViewModel(directory: genDocContent)
                        
                let newDirec = DirecModel(context: moc)
                newDirec.name = itemName
                newDirec.created = Date()
                
                do {
                   try moc.save()
                   print("✅ created and saved \(itemName) to coredata")
               } catch {
                   print("❌ FAILED TO UPDATE COREDATA")
               }
                
            } else {
                print("❌ ERROR CONVERTING TO MainDocViewModel")
            }
        } catch {
            print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
        }
    }
}
