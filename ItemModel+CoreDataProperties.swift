//
//  ItemModel+CoreDataProperties.swift
//  docWind
//
//  Created by Sarvad shetty on 7/3/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//
//

import Foundation
import CoreData


extension ItemModel: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemModel> {
        return NSFetchRequest<ItemModel>(entityName: "ItemModel")
    }

    @NSManaged public var itemName: String?
    @NSManaged public var itemType: String?
    @NSManaged public var iconName: String?
    @NSManaged public var itemURL: String?
    @NSManaged public var locked: NSNumber?
    @NSManaged public var itemCreated: Date?
    @NSManaged public var origin: DirecModel?
    
    // created wrapped properties to avoid optionals
    public var wrappedItemUrl: String {
        itemURL ?? "\(DWFMAppSettings.shared.fileURL())"
    }
    
    public var wrappedItemType: String {
        itemType ?? DWDIRECTORY
    }
    
    public var wrappedItemName: String {
        itemName ?? "Unknown name"
    }
    
    public var wrappedLocked: Bool {
        locked as! Bool
    }
    
    public var wrappedItemCreated: Date {
        itemCreated ?? Date()
    }
    
    public var wrappedIconName: String {
        iconName ?? "blue"
    }
    
    static func deleteObject(in managedObjectContext: NSManagedObjectContext, sub: ItemModel) {
        DispatchQueue.main.async {
            managedObjectContext.delete(sub)
            ///SAVE TO CONTEXT
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    static func updateObject(in managedObjectContext: NSManagedObjectContext) {
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
