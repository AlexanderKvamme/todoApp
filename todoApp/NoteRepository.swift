//
//  NoteRepository.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation

protocol NoteRepository {
    func getAllNotes() -> [NoteModel]
    func getNote(withId: Int) {
}
