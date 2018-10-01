//
//  File.swift
//  
//
//  Created by Alexander K on 14/04/2018.
//

import Foundation

// MARK: - Methods

extension Note {
    
    // MARK: Booleans
    
    func isNumbered() -> Bool {
        return self.number != -1
    }
    
    // MARK: Text methods
    
    func getText() -> String {
        if let content = content { return content } else { return "TEXT MISSING" }
    }
    
    func setText(_ string: String) {
        content = string
    }
    
    // MARK: isPinned methods
    
    func setPinned(_ bool: Bool) {
        isPinned = bool
        if isPinned {
            decrementNoteNumbersOver(self.number)
            self.number = -1
        } else {
            number = 0
            category?.incrementUnpinnedNumbers()
        }
    }
    
    func isLast() -> Bool {
        guard let cat = category else {
            assertionFailure()
            return false
        }
        
        let isLast = cat.getAllNotes()?.last == self
        print("note: \(content!) isLast: \(isLast)")
        return isLast
    }
    
    func removeNumber() {
        number = -1
    }

    private func decrementNoteNumbersOver(_ n: Int16) {
        DatabaseFacade.getNotes(category!, pinned: false).filter({$0.number>n}).forEach({$0.number -= 1})
    }

    // MARK: AwakeFromInsert

    public override func awakeFromInsert() {
        self.dateCreated = Date()
        //self.category = DatabaseFacade.defaultCategory
    }
}

