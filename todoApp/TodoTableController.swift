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
        
        // Position refresh below navbar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        addPullToRefresh()
        tableView.reloadData()
    }
    
    // MARK: - Methods
    
    private func setupTableView() {
        // tableView
        tableView.dataSource = dataSource
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
//        tableView.separatorStyle = .none

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func addPullToRefresh() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.green
        
        // Add pull to refresh
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.red)
    }
}

