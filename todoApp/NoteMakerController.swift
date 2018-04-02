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
    
    let storage: NoteStorage
    
    // MARK: - Initializer
    
    init(withStorage storage: NoteStorage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
        
        addWhiteView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .green
    }
    
    fileprivate func addWhiteView() {
        let whiteView = UIView()
        whiteView.backgroundColor = .red
        
        view.addSubview(whiteView)
        
        whiteView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}

// MARK: - Custom transition

extension NoteMakerController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("*bama preparing for segue in notemaker*")
        
        if type(of: segue.source) == TodoTableController.self {// && segue.destination == NoteMakerController.self {
            print("*bama was RIGHT segue target and source*")
        } else {
            print("*bama was WRONG segue target and source*")
        }
    }
}

