//
//  NoteDataSource.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import SwipeCellKit
import Foundation
import UIKit


class NoteDataSource: NSObject {
    
    // MARK: - Properties
    
    let noteStorage: NoteStorage
    var notes: [Note]
    
    // MARK: - Initializer
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.notes = noteStorage.getAllNotes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods

    func injectNote(_ note: Note, at index: Int) {
        notes.insert(note, at: index)
    }
    
    func deleteNote(at index: Int) {
        let noteToRemove = notes[index]
        notes.remove(at: index)
        noteStorage.delete(note: noteToRemove)
    }
}

// MARK: - UITableViewDataSource conformance

extension NoteDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentIndex = indexPath.row
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier) as? NoteCell else {
            let newCell = NoteCell(frame: .zero)
            newCell.delegate = self
            let tempNode = notes[currentIndex]
            newCell.updateWith(note: tempNode)
            return newCell
        }
        
        cell.delegate = self
        cell.updateWith(note: notes[currentIndex])
        return cell
    }
}

/// Enables swiping on cells to delete 
extension NoteDataSource: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        switch orientation {
        case .left:
            var options = SwipeTableOptions()
            options.expansionStyle = .destructive
            options.transitionStyle = .border
            return options
        case .right:
            var options = SwipeTableOptions()
            options.expansionStyle = SwipeExpansionStyle.fill
            options.transitionStyle = .drag
            return options
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        log.warning("editActionsForRowAt")
        
        switch orientation {
        case .left:
            log.warning(" - Swipe from left")
            let deleteAction = SwipeAction(style: .destructive, title: "DELETE") { (action, ip) in
                self.deleteNote(at: ip.row)
            }
            return [deleteAction]
        case .right:
            let pinAction = SwipeAction(style: .default, title: "PIN") { (action, ip) in
                print("pin action triggered: \(action): for ip:", ip)
            }
            return [pinAction]
        }
    }
}

