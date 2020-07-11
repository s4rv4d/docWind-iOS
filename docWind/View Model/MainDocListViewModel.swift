//
//  MainDocListViewModel.swift
//  docWind
//
//  Created by Sarvad shetty on 7/3/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI
import CoreData

final class MainDocListViewModel: ObservableObject {
 
    // MARK: - Properties
    @Published var contents: MainDocViewModel? = nil
    @Published var direcObject: DirecModel? = nil
    
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
                self.direcObject = docWindContent
            } else {
                print("❌ ERROR CONVERTING TO MainDocViewModel")
            }
        } catch {
            print("❌ ERROR RETRIEVING DATA FOR DOCWIND DIRECTORY")
        }
        
    }
    
    func addANewItem(itemName: String, iconName: String, itemType: String, locked:Bool, filePath: String) {
        // declare the moc(managed object context)
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //make a single object observation request
        let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
        fetchRequest.predicate = NSPredicate(format: "name == %@", "DocWind")
        
        do {
            let content = try moc.fetch(fetchRequest)

            if let docWindContent = content.first {
                self.contents = MainDocViewModel(directory: docWindContent)
                self.direcObject = docWindContent
                                
                // add new item
                let itemName = itemName
                let iconName = iconName
                let itemType = itemType
                let isLocked = locked
                
                let item = ItemModel(context: moc)
                item.itemName = itemName
                item.itemType = itemType
                item.itemURL = filePath
                item.iconName = iconName
                item.locked = NSNumber(booleanLiteral: isLocked)
                item.itemCreated = Date()
                item.origin = direcObject
                
                direcObject?.addToFiles(item)
                self.contents = MainDocViewModel(directory: direcObject!)
                        
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
    
    func addANewItemForFile(itemName: String, iconName: String, itemType: String, locked:Bool, filePath: String) {
        // declare the moc(managed object context)
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //make a single object observation request
        let fetchRequest = NSFetchRequest<DirecModel>(entityName: "DirecModel")
        fetchRequest.predicate = NSPredicate(format: "name == %@", "DocWind")
        
        do {
            let content = try moc.fetch(fetchRequest)

            if let docWindContent = content.first {
                self.contents = MainDocViewModel(directory: docWindContent)
                self.direcObject = docWindContent
                                
                // add new item
                let itemName = itemName
                let iconName = iconName
                let itemType = itemType
                let isLocked = locked
                
                let item = ItemModel(context: moc)
                item.itemName = itemName
                item.itemURL = filePath
                item.itemType = itemType
                item.iconName = iconName
                item.locked = NSNumber(booleanLiteral: isLocked)
                item.itemCreated = Date()
                item.origin = direcObject
                
                direcObject?.addToFiles(item)
                self.contents = MainDocViewModel(directory: direcObject!)
                        
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
