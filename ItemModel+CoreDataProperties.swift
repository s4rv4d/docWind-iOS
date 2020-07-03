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


extension ItemModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemModel> {
        return NSFetchRequest<ItemModel>(entityName: "ItemModel")
    }

    @NSManaged public var itemName: String?
    @NSManaged public var itemType: String?
    @NSManaged public var origin: DirecModel?
    
    // created wrapped properties to avoid optionals
    public var wrappedItemType: String {
        itemType ?? "Unknown type"
    }
    
    public var wrappedItemName: String {
        itemName ?? "Unknown name"
    }
}
