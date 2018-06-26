//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Alexander K on 26/06/2018.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var hexColor: String?
    @NSManaged public var name: String?
    @NSManaged public var id: Int16
    @NSManaged public var isNumbered: Bool
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for notes
extension Category {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
