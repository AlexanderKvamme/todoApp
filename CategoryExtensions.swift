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
        return numberedNotes
    }
    
    func getPinnedNotes() -> [Note] {
        return DatabaseFacade.getNotes(self, pinned: true)
    }
    
    func getUnpinnedNotes() -> [Note] {
        return DatabaseFacade.getNotes(self, pinned: false)
    }
    
    func incrementUnpinnedNumbers() {
        getUnpinnedNotes().forEach({ $0.number.increment() })
    }
    
    func getHighestNumber() -> Int16 {
        guard let numbers = getAllNotes()?.compactMap({$0.number}) else { return 0 }
        
        if let maxNumber = numbers.max() {
            return maxNumber == -1 ? 0 : maxNumber
        }
        
        return 0
    }
}

// MARK: - Int16 extensions

extension Int16 {
    mutating func increment() {
        self = self + 1
    }
}
