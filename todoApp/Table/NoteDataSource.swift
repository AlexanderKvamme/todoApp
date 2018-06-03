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
    
    let minimumCells = 10 // if you only have 2 cells, 8 of them will be empty and uneditable, to avoid having to reload cells which makes the table jump
    
    weak var delegate: NoteTableController?

    // Computed
    
    var hasPinnedNotes: Bool {
        guard hasNotes else { return false }
        guard let firstNote = notes.first  else { return false }
        return firstNote.isPinned
    } 
    
    var hasNotes: Bool {
        return self.notes.count > 0
    }
    
    // MARK: - Initializer
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.notes = noteStorage.getNotes(Categories._default, pinned: true) + noteStorage.getNotes(Categories._default, pinned: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func switchCategory(to category: Category?) {
        guard let category = category else { fatalError("must switch to a category") }
        
        self.notes = noteStorage.getNotes(category, pinned: true) + noteStorage.getNotes(category, pinned: false)
        delegate?.updatePinColors()
        
        print("\(notes.count) notes:" , notes.compactMap({$0.content!}))
    }
    
    func add(_ note: Note) {
        let firstIndexUnderPinned = getFirstIndexUnderPinnedRows()
        notes.insert(note, at: firstIndexUnderPinned)
        delegate?.updatePinColors()
    }
    
    func deleteNote(at index: Int) {
        guard index < notes.count else { fatalError("Out of range") }
        
        let noteToRemove = notes[index]
        notes.remove(at: index)
        noteStorage.delete(note: noteToRemove)
        noteStorage.save()
        delegate?.updatePinColors()
        insertNewBlankCell()
    }
    
    func insertNewBlankCell() {
        delegate?.insertNewBlankCell()
    }
    
    func togglePinned(at index: Int) {
        
        guard index < notes.count else { return }
        
        if notes[index].isPinned {
            unpinNote(at: index)
        } else {
            pinNote(at: index)
        }
        DatabaseFacade.saveContext()
        delegate?.updatePinColors()
    }
    
    func getLastNote() -> Note? {
        if notes.count == 0 { return nil }
        return notes[notes.count-1]
    }
    
    func pinNote(at index: Int) {
        guard let table = delegate?.tableView else {return}
        
        let noteToPin = notes[index]
        let fromIndex = IndexPath(row: index, section: 0)
        let toIndex = IndexPath(row: 0, section: 0)

        delegate?.playPinSound()
        
        table.beginUpdates()
        notes.remove(at: index)
        noteToPin.setPinned(true)
        notes.insert(noteToPin, at: 0)
        table.deleteRows(at: [fromIndex], with: .automatic)
        table.insertRows(at: [toIndex], with: .automatic)
        table.endUpdates()
    }
    
    func unpinNote(at index: Int) {
        delegate?.playUnpinSound()
        let noteToUnpin = notes[index]
        notes.remove(at: index)
        noteToUnpin.setPinned(false)
        notes.append(noteToUnpin)
        
        let fromIndex = IndexPath(row: index, section: 0)
        let toIndex = IndexPath(row: notes.count-1, section: 0)
        
        if let table = delegate?.tableView {
            table.beginUpdates()
            table.deleteRows(at: [fromIndex], with: .automatic)
            table.insertRows(at: [toIndex], with: .automatic)
            table.endUpdates()
        }
    }
    
    func index(of note: Note) -> IndexPath {
        return IndexPath(row: notes.index(of: note)!, section: 0)
    }
    
    func getFirstIndexUnderPinnedRows() -> Int {
        guard notes.count > 0 else { return 0 }
        
        var currentIndex = 0
        
        while currentIndex < notes.count && notes[currentIndex].isPinned {
            currentIndex += 1
        }
        return currentIndex
    }
    
    func stopTrackingPull() {
        delegate?.tableView.dg_removePullToRefresh()
        delegate?.shouldSwitchCategoryOnPull = false
    }
    
    func startTtrackingPull() {
        delegate?.addPullToRefresh()
        delegate?.shouldSwitchCategoryOnPull = true
    }
}

// MARK: - Helpers

extension NoteDataSource {
    
    var isFull: Bool {
       return notes.count >= minimumCells
    }
}

// MARK: - UITableViewDataSource conformance

extension NoteDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        delegate?.updatePinColors()
        startTtrackingPull()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = max(notes.count, minimumCells)
        return cnt
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentIndex = indexPath.row
        let willBeEmptyCell = currentIndex < notes.count
        let tempNote = currentIndex < notes.count ? notes[currentIndex] : nil
        
        switch willBeEmptyCell {
        case false:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier) as? NoteCell else {
                let newCell = NoteCell(frame: .zero)
                newCell.delegate = self
                newCell.updateWith(note: tempNote)
                return newCell
            }
            
            cell.delegate = self
            cell.updateWith(note: tempNote)
            return cell
        case true:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier) as? NoteCell else {
                let newCell = NoteCell(frame: .zero)
                newCell.delegate = self
                newCell.updateWith(note: tempNote)
                return newCell
            }
            
            cell.delegate = self
            cell.updateWith(note: tempNote)
            return cell
        }
    }
}

/// Enables swiping on cells to delete 
extension NoteDataSource: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard delegate?.tableViewShouldBeEditable == true && notes.count < indexPath.row else {
            log.info("canEditRowAt \(indexPath.row) - false")
            return false
        }
        
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
        guard delegate?.tableViewShouldBeEditable == true && indexPath.row < notes.count else {
            log.info("editActionsForRowAt \(indexPath.row) not returning SwipeAction")
            return nil
        }
        
        stopTrackingPull()
        
        switch orientation {
        case .left:
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, ip) in
                tableView.beginUpdates()
                self.deleteNote(at: ip.row)
                self.delegate?.playDoneSound()
                action.fulfill(with: ExpansionFulfillmentStyle.delete)
                tableView.endUpdates()
            }
            
            deleteAction.image = UIImage.checkmarIcon
            deleteAction.backgroundColor = UIColor.primary.darker(by: 10)
            return [deleteAction]
        case .right:
            let pinAction = SwipeAction(style: .default, title: nil) { (action, ip) in
                self.togglePinned(at: ip.row)
                action.fulfill(with: ExpansionFulfillmentStyle.reset)
            }
            
            pinAction.image = .starIcon
            pinAction.backgroundColor = delegate?.getCurrentCategoryColor()
            return [pinAction]
        }
    }
}

