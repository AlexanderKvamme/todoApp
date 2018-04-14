//
//  CoreDataStorage.swift
//  todoApp
//
//  Created by Alexander K on 10/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

class CoreDataStorage: NoteStorage {

    // MARK: - Methods
    
    func makeNote(withText text: String) -> Note {
        let newNote = DatabaseFacade.makeNote()
        newNote.setText(text)
        DatabaseFacade.saveContext()
        return newNote
    }
    
    func getAllNotes() -> [Note] {
        return DatabaseFacade.getAllNotes() ?? []
    }
    
    func delete(note: Note) {
        DatabaseFacade.delete(note)
        DatabaseFacade.saveContext()
    }
}

