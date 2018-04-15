//
//  File.swift
//  
//
//  Created by Alexander K on 14/04/2018.
//

import Foundation

// MARK: - Methods

extension Note {
    
    // MARK: Text methods
    
    func getText() -> String {
        return content ?? "TEXT MISSING"
    }
    
    func setText(_ string: String) {
        content = string
    }
    
    // MARK: isPinned methods
    
    func setPinned(_ bool: Bool) {
        log.debug("pinning")
        isPinned = bool
    }

    // MARK: AwakeFromInsert

    public override func awakeFromInsert() {
        self.dateCreated = Date()
    }
}

