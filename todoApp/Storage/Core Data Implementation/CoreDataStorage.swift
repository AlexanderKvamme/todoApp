//
//  CoreDataStorage.swift
//  todoApp
//
//  Created by Alexander K on 10/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

class CoreDataStorage: NoteStorage {

    // MARK: Static Properties
    
    static var recoverableNote: Note?
    
    // MARK: Properties
    
    var pinnedNotesCount: Int {
        return DatabaseFacade.pinnedNotesCount
    }
    
    var unpinnedNotesCount: Int {
        return DatabaseFacade.unpinnedNotesCount
    }
    
    // MARK: - Methods
    
    func makeNote(withText text: String?) -> Note? {
        guard let text = text else { return nil }
        guard text != "" else { return nil }
        
        let newNote = DatabaseFacade.makeNote()
        newNote.setText(text)
        DatabaseFacade.saveContext()
        return newNote
    }
    
    // MARK: Getters
    
    func getAllNotes() -> [Note] {
        return DatabaseFacade.getAllNotes() ?? []
    }
    
    func getNotes(pinned: Bool) -> [Note] {
        return DatabaseFacade.getNotes(pinned: pinned)
    }
    
    // MARK: Deletion
    
    func delete(note: Note) {
        CoreDataStorage.deleteRecoverableNote()
        CoreDataStorage.recoverableNote = note
        DatabaseFacade.saveContext()
    }
    
    func undoDeletion() -> Note? {
        if let recoveredNote = CoreDataStorage.recoverableNote {
            CoreDataStorage.recoverableNote = nil
            return recoveredNote
        } else {
            return nil
        }
    }
    
    static func deleteRecoverableNote() {
        if let recoverable = CoreDataStorage.recoverableNote {
            DatabaseFacade.delete(recoverable)
        }
    }
}

