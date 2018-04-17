//
//  NoteMakerController.swift
//  todoApp
//
//  Created by Alexander K on 30/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


// Makes notes
final class NoteMakerController: UIViewController {
    
    // MARK: - Properties
    
    var noteMakerView = NoteMakerView(frame: .zero)
    
    private let storage: NoteStorage
    
    // MARK: - Initializer
    
    init(withStorage storage: NoteStorage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
        
        view = noteMakerView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func makeNoteFromInput() -> Note? {
        if let currentText = noteMakerView.textField.text {
            return storage.makeNote(withText: currentText)
        } else {
            return nil
        }
    }
    
    func animateEndOfEditing() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.noteMakerView.textField.alpha = 0
        }) { (bool) in
            self.resetVisuals()
        }
    }
    
    private func resetVisuals() {
        noteMakerView.textField.alpha = 1
        noteMakerView.textField.text = ""
    }
}

