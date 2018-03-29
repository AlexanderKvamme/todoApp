//
//  MainViewController.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import SnapKit

/// Contains a tableview with a pull to refresh
class TodoTableController: UITableViewController {

    let dataSource: NoteDataSource
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.dataSource = NoteDataSource(with: storage)
        
        super.init(nibName: nil, bundle: nil)
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        tableView.reloadData()
    }
    
    // MARK: - Methods
    
    private func setupTableView() {
        
        tableView.dataSource = dataSource
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}

