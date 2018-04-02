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
        setTransitioningDelegate()
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
    }
    
    // MARK: - Methods
    
    private func setTransitioningDelegate() {
        transitioningDelegate = self
    }
    
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
            
            if let storage = self?.noteStorage, let nav = self?.navigationController {
                let maker = NoteMakerController(withStorage: storage)
                maker.transitioningDelegate = self
//                nav.pushViewController(maker, animated: true)
                if let storage = self?.noteStorage, let nav = self?.navigationController {
                    let maker = NoteMakerController(withStorage: storage)
                    maker.transitioningDelegate = self
                    nav.pushViewController(maker, animated: true)

                    //                    print("*bama gonna transition*")
                    
//                    if let topViewController = nav.topViewController {
//                        print("bama had topvc")
//                        let segue = UIStoryboardSegue(identifier: "mySegue", source: topViewController, destination: maker)
//                        nav.performSegue(withIdentifier: segue.identifier!, sender: self)
//                    }
                }
            }
            
            self?.tableView.dg_stopLoading()
            }, loadingView: nil)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
    }
}

// MARK: - Custom transitions

extension TodoTableController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController,source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            // FIXME: Use black center frams
            print("bama tryna flip")
            return FlipPresentAnimationController(originFrame: view.frame)
    }
}

extension TodoTableController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("*bama preparing for segue in todo*")
    }
}
