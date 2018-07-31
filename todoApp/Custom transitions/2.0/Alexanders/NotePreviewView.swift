//
//  NotePreviewView.swift
//  todoApp
//
//  Created by Alexander K on 31/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


final class NotePreviewView: UIView {

    // MARK: - Properties
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    private func setup() {
        backgroundColor = .green
    }
}

