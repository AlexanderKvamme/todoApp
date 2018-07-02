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
        
        return []
//        return notes.filter($0.isNumbered)
        
    }
}

