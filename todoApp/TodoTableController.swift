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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupView()
        setupTableView()
        addPullToRefresh()
        tableView.reloadData()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        guard let navHeight = navigationController?.navigationBar.frame.height else { return }

        self.tableView.contentInset = UIEdgeInsetsMake(navHeight + 20,0,0,0);
        
        self.edgesForExtendedLayout = []
    }
    
    private func setupTableView() {
        // tableView
        tableView.dataSource = dataSource
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
//        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.separatorStyle = .none

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func addPullToRefresh() {
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            print("*BAM did finish at \(Date())")
            self?.tableView.dg_stopLoading()
            }, loadingView: nil)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
    }
}

