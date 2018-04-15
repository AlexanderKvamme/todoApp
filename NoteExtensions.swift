//
//  File.swift
//  
//
//  Created by Alexander K on 14/04/2018.
//

import Foundation

// MARK: - Methods

extension Note {
    
    func getText() -> String {
        return content ?? "TEXT MISSING"
    }
    
    func setText(_ string: String) {
        content = string
    }

    // MARK: AwakeFromInsert

    public override func awakeFromInsert() {
        self.dateCreated = Date()
    }
}

