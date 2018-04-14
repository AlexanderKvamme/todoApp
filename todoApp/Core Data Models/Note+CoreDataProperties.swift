//
//  Note+CoreDataProperties.swift
//  
//
//  Created by Alexander K on 10/04/2018.
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

}
