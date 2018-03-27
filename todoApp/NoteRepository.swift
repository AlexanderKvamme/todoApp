//
//  NoteRepository.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

/// Used to easily access and CRUD all notes
protocol NoteRepository {
    func getAllNotes() -> [Note]
}

