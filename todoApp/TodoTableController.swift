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


class test: DGElasticPullToRefreshLoadingView {
    
}

/// Contains a tableview with a pull to refresh
class TodoTableController: UITableViewController {

    private let noteStorage: NoteStorage
    private let dataSource: NoteDataSource
    private lazy var noteMaker = NoteMakerController(withStorage: self.noteStorage)
    
    lazy var navHeight = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
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
        self.tableView.contentInset = UIEdgeInsetsMake(navHeight + 20,0,0,0);
        self.edgesForExtendedLayout = []
    }
    
    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.backgroundColor = .red
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
    }

    /// Presents a notemaker over the first cell and lets user make a note. if user saves, the note is injected into the table
    private func addPullToRefresh() {
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
//            guard let storage = self?.noteStorage,
//                let tableView = self?.tableView else {
//                    log.debug("Missing values")
//                    return
//            }
            
            // Add NoteMaker
//            self?.noteMaker = NoteMakerController(withStorage: storage)
//            guard let noteMaker = self?.noteMaker else { fatalError() }
//            noteMaker.textField.delegate = self
//
//            self?.addChildViewController(noteMaker)
//            self?.view.addSubview(noteMaker.view)
            
//            noteMaker.transitioningDelegate = self
            
//            if let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
//                // use first cell
//                let firstCellFrame = firstCell.frame
//
//                noteMaker.view.snp.makeConstraints({ (make) in
//                    //make.size.equalTo(firstCellFrame.size)
//                    //make.center.equalTo(firstCell.snp.center)
//                    make.top.equalTo(self!.navigationController.view.snp.top)
//                    make.left.equalTo(tableView.snp.left)
//                    make.right.equalTo(tableView.snp.right)
//                    make.bottom.equalTo(firstCell.snp.top)
//                })
//            } else {
//                // No first cell to model after
//            }
            
            self?.tableView.dg_stopLoading()
            }, loadingView: self.noteMaker.view as? DGElasticPullToRefreshLoadingView)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
    }
    
    func dismissNoteMaker() {
        log.debug("would dismiss notemaker")
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

extension TodoTableController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("did begin")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.debug("Should return")
        textField.resignFirstResponder()
        
        dismissNoteMaker()
        
        return true
    }
}
