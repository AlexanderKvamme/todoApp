//
//  NoteStorage.swift
//  todoApp
//
//  Created by Alexander K on 28/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation


protocol NoteStorage {
    var unpinnedNotesCount: Int { get }
    var pinnedNotesCount: Int { get }

    func getAllNotes() -> [Note]
    func getNotes(pinned: Bool) -> [Note]
    
    func delete(note: Note)
    func makeNote(withText text: String?) -> Note?
}

