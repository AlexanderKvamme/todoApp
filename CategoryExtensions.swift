//
//  CategoryExtensions.swift
//  todoApp
//
//  Created by Alexander K on 02/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Category {
    func getAllNotes() -> [Note]? {
        return DatabaseFacade.getNotes(withCategory: self)
    }
    
    func numberedNotes() -> [Note] {
        guard let notes = getAllNotes() else { return [] }
        
        let numberedNotes = notes.filter({$0.isNumbered()})
        
        print("numbered notes in \(self.name) is \(numberedNotes.compactMap({$0.getText()}))")
        return numberedNotes
    }
    
    func incrementNumbers() {
        if let notes = getAllNotes() {
            notes.forEach({ $0.number.increment() })
        }
    }
}

// MARK: - Int16 extensions

extension Int16 {
    mutating func increment() {
        self = self + 1
    }
}
