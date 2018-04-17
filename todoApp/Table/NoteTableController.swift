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

// MARK: - Custom Notifications

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
        
        addObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
//        setupNavbar()
        setupTableView()
        addPullToRefresh()
        setTransitioningDelegate()
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        updateDGColors()
    }

    // MARK: - Methods
    
    /// Sets the color of the pulldown wave to dijon if top note is pinned
    func updateDGColors() {
        let hasPins = dataSource.hasPinnedNotes
        setDGColors(hasPins: hasPins)
    }
    
    private func setDGColors(hasPins: Bool) {
        switch hasPins {
        case true:
            tableView.dg_setPullToRefreshBackgroundColor(UIColor.dijon)
            tableView.backgroundColor = UIColor.dijon
        case false:
            tableView.dg_setPullToRefreshBackgroundColor(UIColor.primary)
            tableView.backgroundColor = UIColor.primary
        }
    }
    
    private func setTransitioningDelegate() {
        transitioningDelegate = self
    }
    
    private func setupNavbar() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    /// Presents a notemaker over the first cell and lets user make a note. if user saves, the note is injected into the table
    private func addPullToRefresh() {
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.handlePullToRefreshCompletion()
            }, loadingView: noteMaker.view as? DGElasticPullToRefreshLoadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor.secondary)
    }
    
    func dismissNoteMaker() {
        // Make note only if it has text
        if let newNote = noteMaker.makeNoteFromInput() {
            // insert new note as a cell
            dataSource.add(newNote)
            let insertionRow = dataSource.index(of: newNote)
            tableView.insertRows(at: [insertionRow], with: .automatic)
            self.tableView.dg_stopLoading()
        } else {
            self.tableView.dg_stopLoading()
        }
    }
    
    // MARK: - Observer Methods
    
    private func addObservers(){
        // Observe when pulled enough to trigger
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPull), name: .DGPulledEnoughToTrigger, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPullAndRelease), name: .DGPulledEnoughToTriggerAndReleased,object: nil)
    }
    
    // MARK: Handlers
    
    @objc func handleHardPull() {
        VibrationController.vibrate()
    }
    
    @objc func handleHardPullAndRelease() {
        let todoTextField = noteMaker.noteMakerView.textField
        todoTextField.delegate = self
        todoTextField.becomeFirstResponder()
    }
    
    func handlePullToRefreshCompletion() {
        print("Pull to refresh action handler triggered")
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("should return")
        dismissNoteMaker()
        noteMaker.animateEndOfEditing()
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("textFieldDidEndEditing")
    }
}

