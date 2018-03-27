//
//  NoteModel.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: NoteID



struct NoteID: String {
    
    // MARK: Properties
    
    private var category: Int
    private var ID: Int
}

// MARK: Note

class Note {
    private let dateCreated  = Date()
    private var text = ""
    
    // MARK: Initializers
    
    init(_ str: String) {
        self.text = str
    }
}

//  MARK: - Extension

extension Note {
    func getStub() -> Note {
        let note = Note(
    }
}
