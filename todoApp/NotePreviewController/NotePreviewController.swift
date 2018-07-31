
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
    private var previewView = NotePreviewView()
    
    // MARK: - Initializers
    
    init(with note: Note, on parentView: UIView) {
        self.currentNote = note
        
        super.init(nibName: nil, bundle: nil)
        
        setup(on: parentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    private func setup(on parentView: UIView) {
        view.backgroundColor = .clear
        view.addSubview(previewView)
        
        previewView.snp.makeConstraints { (make) in
            make.height.equalTo(200)
            make.width.equalTo(200)
            make.center.equalTo(view.snp.center)
        }
    }
}

