//
//  NoteDataSource.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class NoteDataSource: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    
    let noteStorage: NoteStorage
    let notes: [Note]
    
    // MARK: - Initializer
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.notes = noteStorage.getNotes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentIndex = indexPath.row
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier) as? NoteCell else {
            let newCell = NoteCell(frame: .zero)
            let tempNode = notes[currentIndex]
            newCell.updateWith(note: tempNode)
            print("*returning cell*")
            return newCell
        }
        
        cell.updateWith(note: notes[currentIndex])
        print("*returning cell*")
        return cell
    }
}

