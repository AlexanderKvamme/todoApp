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
class NoteTableController: UITableViewController {

    private let noteStorage: NoteStorage
    private let tableViewDelegate: NoteDelegate
    private let dataSource: NoteDataSource
    private lazy var noteMaker = NoteMakerController(withStorage: self.noteStorage)
    
    lazy var navHeight = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.dataSource = NoteDataSource(with: storage)
        self.tableViewDelegate = NoteDelegate()
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
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
        tableView.backgroundColor = .primary
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
    }

    /// Presents a notemaker over the first cell and lets user make a note. if user saves, the note is injected into the table
    private func addPullToRefresh() {
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            let todoTextField = (self?.noteMaker.view as! NoteMakerView).textField
            todoTextField.delegate = self
            todoTextField.becomeFirstResponder()
            }, loadingView: self.noteMaker.view as? DGElasticPullToRefreshLoadingView)
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.clear)
        tableView.dg_setPullToRefreshFillColor(UIColor.secondary)
    }
    
    func dismissNoteMaker() {
        guard let textOfNewNote = (self.noteMaker.view as! NoteMakerView).textField.text else {
            self.tableView.dg_stopLoading()
            return
        }
        
        // insert new note as a cell
        let newNote = noteStorage.makeNote(withText: textOfNewNote)
        dataSource.add(newNote)
        let insertionRow = dataSource.index(of: newNote)
        tableView.insertRows(at: [insertionRow], with: .automatic)
        self.tableView.dg_stopLoading()
    }
}

// MARK: - Custom transitions

extension NoteTableController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController,source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            // FIXME: Use black center frams
            return FlipPresentAnimationController(originFrame: view.frame)
    }
}

extension NoteTableController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("*bama preparing for segue in todo*")
    }
}

extension NoteTableController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("did begin Editing")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        dismissNoteMaker()
        
        return true
    }
}
