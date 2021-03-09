//
//  PdfFilemodel+CoreDataProperties.swift
//  docWind
//
//  Created by Sarvad shetty on 7/3/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//
//

import Foundation
import CoreData


extension PdfFilemodel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PdfFilemodel> {
        return NSFetchRequest<PdfFilemodel>(entityName: "PdfFilemodel")
    }

    @NSManaged public var author: String?
    @NSManaged public var created: Date?
    @NSManaged public var name: String?

}
