//
//  UserDefaultsService.swift
//  todoApp
//
//  Created by Alexander K on 28/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

class UserDefaultsStorage: NoteStorage {
    
    func save(note: Note) {
        print("*would save*")
    }
    
    func getNotes() -> [Note] {
        print("*getting notes*")
        return [Note("Take out the trash"),
                Note("Go buy a donut"),
                Note("Go to the donut"),
                Note("Get a freelance gig"),
            ]
    }
    
    func delete(note: Note) {
        print("*would delete note with content: ", note.getText())
    }
}

