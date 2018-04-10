//
//  NoteModel.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

/// MARK: Note
struct Note {
    private let dateCreated  = Date()
    private var text = ""
    
    // MARK: Initializers
    
    init(_ str: String) {
        self.text = str
    }
    
    // ARRK: - Methods
    
    func getText() -> String {
        return text
    }
}

//  MARK: - Stub Extension

extension Note {
    func getStub() -> Note {
        return Note("Remember to do the dishes")
    }
}

