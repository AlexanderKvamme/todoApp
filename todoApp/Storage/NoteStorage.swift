//
//  NoteStorage.swift
//  todoApp
//
//  Created by Alexander K on 28/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation


protocol NoteStorage {
    func getAllNotes() -> [Note]
    func delete(note: Note)
    func makeNote(withText text: String) -> Note
}

