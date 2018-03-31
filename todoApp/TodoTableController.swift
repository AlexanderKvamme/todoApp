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

    let noteStorage: NoteStorage
    let dataSource: NoteDataSource
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.dataSource = NoteDataSource(with: storage)
        
        super.init(nibName: nil, bundle: nil)
        
        setupNavbar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupNavbar()
        setupTableView()
        addPullToRefresh()
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
    }
    
    // MARK: - Methods
    
    private func setupNavbar() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    private func setupView() {
        guard let navHeight = navigationController?.navigationBar.frame.height else { return }

        self.tableView.contentInset = UIEdgeInsetsMake(navHeight + 20,0,0,0);
        self.edgesForExtendedLayout = []
    }
    
    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
    }
    
    private func addPullToRefresh() {
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            print("*BAM did finish at \(Date())")
            
            if let storage = self?.noteStorage, let nav = self?.navigationController {
                let maker = NoteMakerController(withStorage: storage)
                nav.pushViewController(maker, animated: true)
            }
            
            self?.tableView.dg_stopLoading()
            }, loadingView: nil)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
    }
}

