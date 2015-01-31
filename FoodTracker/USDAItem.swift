//
//  USDAItem.swift
//  FoodTracker
//
//  Created by Clint on 1/31/15.
//  Copyright (c) 2015 Republic. All rights reserved.
//

import Foundation
import CoreData

//Always do this always
@objc (USDAItem)

class USDAItem: NSManagedObject {

    @NSManaged var calcium: String
    @NSManaged var carbohydrate: String
    @NSManaged var cholesterol: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var energy: String
    @NSManaged var fatTotal: String
    @NSManaged var idValue: String
    @NSManaged var name: String
    @NSManaged var protein: String
    @NSManaged var sugar: String
    @NSManaged var vitaminC: String

}
