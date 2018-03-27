//
//  NoteModel.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: NoteID

struct NoteID {
    
    // MARK: Properties
    
    private var prefix: String
    private var number: Int
    
}

// MARK: Note

class Note {
    private let dateCreated = Date()
    private let id: NoteID
    private var text = ""
    private var getID
}

