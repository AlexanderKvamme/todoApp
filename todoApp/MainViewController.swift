//
//  MainViewController.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    // MARK: - Properties
    
    let dataSource: NoteDataSource
    
    // MARK: - Initializers
    
    init(withStorage storage: NoteStorage) {
        dataSource = NoteDataSource(with: storage)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        tableView = UITableView()
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.dataSource = dataSource
    }
}

