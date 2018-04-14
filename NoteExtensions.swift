//
//  File.swift
//  
//
//  Created by Alexander K on 14/04/2018.
//

import Foundation

extension Note {
    
    // MARK: - Methods
    
    func getText() -> String {
        return content ?? "TEXT MISSING"
    }
    
    func setText(_ string: String) {
        content = string
    }
}
