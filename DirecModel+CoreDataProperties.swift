//
//  DirecModel+CoreDataProperties.swift
//  docWind
//
//  Created by Sarvad shetty on 7/3/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//
//

import Foundation
import CoreData


extension DirecModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DirecModel> {
        return NSFetchRequest<DirecModel>(entityName: "DirecModel")
    }

    @NSManaged public var created: Date?
    @NSManaged public var name: String?
    @NSManaged public var files: NSSet?
    
    // creating wrapped variables to avoid optionals
    public var wrappedCreated: Date {
        created ?? Date()
    }
    
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var fileArray: [ItemModel] {
        let set = files as? Set<ItemModel> ?? []
        return set.sorted {
            $0.wrappedItemName < $1.wrappedItemName
        }
    }
    
    static func deleteObject(in managedObjectContext: NSManagedObjectContext, sub: DirecModel) {
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

// MARK: Generated accessors for files
extension DirecModel {

    @objc(addFilesObject:)
    @NSManaged public func addToFiles(_ value: ItemModel)

    @objc(removeFilesObject:)
    @NSManaged public func removeFromFiles(_ value: ItemModel)

    @objc(addFiles:)
    @NSManaged public func addToFiles(_ values: NSSet)

    @objc(removeFiles:)
    @NSManaged public func removeFromFiles(_ values: NSSet)

}
