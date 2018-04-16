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
    
    weak var delegate: NoteTableController?
    
    // MARK: - Initializer
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.notes = noteStorage.getNotes(pinned: true) + noteStorage.getNotes(pinned: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func add(_ note: Note) {
        notes.insert(note, at: 0)
    }
    
    func deleteNote(at index: Int) {
        let noteToRemove = notes[index]
        notes.remove(at: index)
        noteStorage.delete(note: noteToRemove)
    }
    
    func togglePinned(at index: Int) {
        if notes[index].isPinned {
            unpinNote(at: index)
        } else {
            pinNote(at: index)
        }
    }
    
    func pinNote(at index: Int) {
        let noteToPin = notes[index]
        notes.remove(at: index)
        noteToPin.setPinned(true)
        notes.insert(noteToPin, at: 0)
        
        let fromIndex = IndexPath(row: index, section: 0)
        let toIndex = IndexPath(row: 0, section: 0)
        
        if let table = delegate?.tableView {
            table.moveRow(at: fromIndex, to: toIndex)
        }
    }
    
    func unpinNote(at index: Int) {
        let noteToUnpin = notes[index]
        notes.remove(at: index)
        noteToUnpin.setPinned(false)
        notes.append(noteToUnpin)
        
        let fromIndex = IndexPath(row: index, section: 0)
        let toIndex = IndexPath(row: notes.count-1, section: 0)
        
        if let table = delegate?.tableView {
            table.moveRow(at: fromIndex, to: toIndex)
        }
    }
    
    func index(of note: Note) -> IndexPath {
        return IndexPath(row: notes.index(of: note)!, section: 0)
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
        
        switch orientation {
        case .left:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, ip) in
                self.deleteNote(at: ip.row)
            }
            deleteAction.image = UIImage.checkmarIcon
            deleteAction.backgroundColor = .green
            return [deleteAction]
        case .right:
            // TODO: - Make switch. If already pinned, unpin with another color than dijon
            let pinAction = SwipeAction(style: .default, title: nil) { (action, ip) in
//                self.pinNote(at: ip.row)
                self.togglePinned(at: ip.row)
            }
            pinAction.image = .starIcon
            pinAction.backgroundColor = .dijon
            return [pinAction]
        }
    }
}

