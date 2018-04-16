//
//  CoreDataFacade.swift
//  todoApp
//
//  Created by Alexander K on 10/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


enum Entity: String {
    case Note = "Note"
}


final class DatabaseFacade {
    
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
    
    static func getNotes(pinned: Bool) -> [Note] {
        
        var result: [Note] = []
        
        do {
            let fetchRequest = NSFetchRequest<Note>(entityName: Entity.Note.rawValue)
            fetchRequest.predicate = NSPredicate(format: "isPinned == \(pinned)")
            result = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("error fetching pinned/unpinned notes: \(error.localizedDescription)")
        }
        return result
    }
    
//    static func getMuscle(named name: String) -> Note? {
//        let name = name.uppercased()
//        var note: Note? = nil
//        do {
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Note.rawValue)
//            let result = try context.fetch(fetchRequest)
//            note = result.first as? Muscle
//        } catch let error as NSError {
//            print("error fetching \(name): \(error.localizedDescription)")
//        }
//        return note
//    }
}

