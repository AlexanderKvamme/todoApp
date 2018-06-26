//
//  CoreDataFacade.swift
//  todoApp
//
//  Created by Alexander K on 10/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData
import UIKit


fileprivate enum Entity: String {
    case Note = "Note"
    case Category = "Category"
}


struct Categories {
    static let firstCategory = DatabaseFacade.forceFetchCategory(id: 0, color: UIColor.categories._default)
    static let secondCategory = DatabaseFacade.forceFetchCategory(id: 1, color: UIColor.categories.pleasure)
    static let thirdCategory = DatabaseFacade.forceFetchCategory(id: 2, color: UIColor.categories.business)
    static let fourthCategory = DatabaseFacade.forceFetchCategory(id: 3, color: UIColor.categories.groceries)
    
    static let all = [firstCategory, secondCategory, thirdCategory, fourthCategory]
    static let count = all.count
}

final class DatabaseFacade {
    
    static var defaultCategory: Category = { return Categories.firstCategory }()

    // MARK: - Initializers
    
    private init(){}
    
    // MARK: - Properties
    
    static var pinnedNotesCount: Int {
        var count = 0
        
        do {
            let fr = NSFetchRequest<Note>(entityName: Entity.Note.rawValue)
            fr.predicate = NSPredicate(format: "isPinned = true")
            let result = try context.fetch(fr)
            count = result.count
        } catch let error {
            log.warning(error)
        }
        
        return count
    }

    static var unpinnedNotesCount: Int {
        var count = 0

        do {
            let fr = NSFetchRequest<Note>(entityName: Entity.Note.rawValue)
            fr.predicate = NSPredicate(format: "isPinned = false")
            let result = try context.fetch(fr)
            count = result.count
        } catch let error {
            log.warning(error)
        }
        
        return count
    }
    
    static var categoryCount: Int {
        var count = 0
        
        do {
            let fr = NSFetchRequest<Category>(entityName: Entity.Category.rawValue)
            let result = try context.fetch(fr)
            count = result.count
        } catch let error {
            log.warning(error)
        }
        
        print("returning count: ", count)
        return count
    }
    
    // MARK: Fundamentals
    
    static var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "todoApp")
        persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            if let error = error {
                print("error: ", error)
            }
        })
        return persistentContainer
    }()
    
    static var context: NSManagedObjectContext = {
        return DatabaseFacade.persistentContainer.viewContext
    }()
    
    // MARK: - Methods
    
    static func saveContext() {
        guard persistentContainer.viewContext.hasChanges else { return }

        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("error saving to persistentContainers viewContext")
        }
    }
    
    // MARK: Deletion methods
    
    /// Allow for custom deletion behaviour based on type, while DatabaseFacade exposes this simple abstraction
    static func delete(_ objectToDelete : NSManagedObject) {
        switch objectToDelete {
        case let note as Note:
            deleteNote(note)
        default:
            print("Missing specialized deletion method for \(type(of: objectToDelete)). Defaulting to context.delete")
            persistentContainer.viewContext.delete(objectToDelete)
        }
        
        saveContext()
    }
    
    
    private static func deleteNote(_ noteToDelete: Note) {
        persistentContainer.viewContext.delete(noteToDelete)
    }
    
    // MARK: Creation methods
    
    private static func createManagedObjectForEntity(_ entity: Entity) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        var result: NSManagedObject? = nil
        
        let entityDescription = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context)
        if let entityDescription = entityDescription {
            result = NSManagedObject(entity: entityDescription, insertInto: context)
        }
        return result
    }
    
    static func makeNote() -> Note {
        let newNote = createManagedObjectForEntity(.Note) as! Note
        return newNote
    }
    
    static func makeCategory(id: Int, named name: String, color hexColor: String) -> Category {
        let newCategory = createManagedObjectForEntity(.Category) as! Category
        newCategory.id = Int16(id)
        newCategory.name = name
        newCategory.hexColor = hexColor
        return newCategory
    }
    
    static func getAllNotes() -> [Note]? {
        var result: [Note]? = nil
        
        do {
            let fr = NSFetchRequest<Note>(entityName: Entity.Note.rawValue)
            fr.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.dateCreated), ascending: false)]
            result = try context.fetch(fr)
        } catch let error {
            log.warning(error)
        }
        
        return result
    }
    
    static func getNotes(withCategory category: Category?) -> [Note]? {
        var result: [Note]? = nil
        
        do {
            let fr = NSFetchRequest<Note>(entityName: Entity.Note.rawValue)
            
            if let category = category {
                fr.predicate = NSPredicate(format: "category == %@", category)
            } else {
                fr.predicate = NSPredicate(format: "category == nil")
            }
            result = try context.fetch(fr)
        } catch let error {
            log.warning(error)
        }
        return result
    }
    
    static func defaultName(_ id: Int) -> String {
    
        switch id {
        case 1:
            return "To do today"
        default:
            return "Category \(id)"
        }
    }
    
    static func forceFetchCategory(id: Int, color hexColor: UIColor) -> Category {
        var result: [Category]? = nil
        
        do {
            let fr = NSFetchRequest<Category>(entityName: Entity.Category.rawValue)
            let predicate = NSPredicate(format: "id == %@", NSNumber(integerLiteral: id))
            fr.predicate = predicate
            result = try context.fetch(fr)
        } catch let error {
            log.warning(error)
        }
        
        if let fetchedCategory = result?.first {
            fetchedCategory.hexColor = hexColor.toHexString()
        }
        return result?.first ?? makeCategory(id: id, named: defaultName(id), color: hexColor.toHexString())
    }
    
    static func getNotes(_ category: Category, pinned: Bool) -> [Note] {
        var result: [Note] = []
        
        do {
            let fetchRequest = NSFetchRequest<Note>(entityName: Entity.Note.rawValue)
            let isPinnedPredicate = NSPredicate(format: "isPinned == \(pinned)")
            let categoryPredicate = NSPredicate(format: "category = %@", category)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isPinnedPredicate, categoryPredicate])
            result = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("error fetching pinned/unpinned notes: \(error.localizedDescription)")
        }
        return result
    }
}

