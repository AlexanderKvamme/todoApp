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
    
    private let storage: NoteStorage
    
    // MARK: - Initializer
    
    init(withStorage storage: NoteStorage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
        
        view = NoteMakerView(frame: .zero)
        
        addSubviewsAndConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .purple
    }
    
    override func viewDidAppear(_ animated: Bool) {
        log.debug("view did appear")
    }
    
    // MARK: - Methods
    
    private func addSubviewsAndConstraints() {
        // -
    }
}

