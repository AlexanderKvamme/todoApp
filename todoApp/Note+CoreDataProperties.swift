//
//  Note+CoreDataProperties.swift
//  
//
//  Created by Alexander K on 02/07/2018.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var isPinned: Bool
    @NSManaged public var number: Int16?
    @NSManaged public var category: Category? {
        didSet {
            print("did set category of note '\(content)' - \(self.category)")
        }
    }

}
