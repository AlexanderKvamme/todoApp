
//
//  NotePreviewController.swift
//  todoApp
//
//  Created by Alexander K on 24/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

final class NotePreviewController: UIViewController {

    // MARK: - Properties
    
    private var currentNote: Note
    private let backgroundView = UIView()
    private let notePreviewView = NotePreviewView()
    private let indexPathOfNote: IndexPath
    
    weak var owner: NoteTableController?
    
    // MARK: - Initializers
    
    init(with note: Note, on parentView: UIView, at indexPath: IndexPath) {
        self.currentNote = note
        self.indexPathOfNote = indexPath
        
        super.init(nibName: nil, bundle: nil)
        
        setup(on: parentView)
        notePreviewView.update(with: note)
        addDismissTapRecognizer()
        notePreviewView.owner = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    private func setup(on parentView: UIView) {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.addSubview(notePreviewView)

        backgroundView.backgroundColor = .clear
        
        backgroundView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.top.equalTo(view.snp.top)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
            
        notePreviewView.snp.makeConstraints { (make) in
            let sideOffset: CGFloat = 20
            let verticalOffset: CGFloat = 100

            make.left.equalTo(view.snp.left).offset(sideOffset)
            make.top.equalTo(view.snp.top).offset(verticalOffset)
            make.right.equalTo(view.snp.right).offset(-sideOffset)
            make.bottom.equalTo(view.snp.bottom).offset(-verticalOffset)
        }
    }
    
    private func addDismissTapRecognizer() {
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(dismissPreviewer))
        backgroundView.addGestureRecognizer(tapRec)
    }
    
    @objc func dismissPreviewer() {
        dismiss(animated: true) {
            log.info("finished dismissing")
        }
        
        owner?.tableView.reloadRows(at: [indexPathOfNote], with: .automatic)
        owner?.animateBackground(visible: false)
    }
}

