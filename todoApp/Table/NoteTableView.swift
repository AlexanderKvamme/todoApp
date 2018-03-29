//
//  NoteTableView.swift
//  todoApp
//
//  Created by Alexander K on 29/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


/// Contains a tableview with a pull to refresh
class MainViewController: UITableViewController {
    
    // MARK: - Properties
    
    let dataSource: NoteDataSource
    
    // MARK: - Initializers
    
    init(withStorage storage: NoteStorage) {
        dataSource = NoteDataSource(with: storage)
        
        super.init(nibName: nil, bundle: nil)
        
        addPullToRefresh()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    // MARK: - Methods
    
    private func setupTableView() {
        view.backgroundColor = .green
        tableView = UITableView()
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
    }
    
    private func addPullToRefresh() {
        // Initialize tableView
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            
            self?.tableView.dg_stopLoading()
            }, loadingView: nil)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
    }
}

