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
import AVFoundation

// MARK: - Custom Notifications

enum Globals {
    static var screenHeight = UIScreen.main.bounds.height
    static var screenWidth = UIScreen.main.bounds.width
}

/// Contains a tableview with a pull to refresh
class NoteTableController: UIViewController, UITableViewDelegate {
    private var audioPlayer = AVAudioPlayer()
    private let noteStorage: NoteStorage
    private var dataSource: NoteDataSource
    private let categoryOfController: Category
    private var currentlySelectedCategory: Category? {
        didSet {
            // FIMXE: refactor
            setPullToRefreshColor(for: currentlySelectedCategory)
            
            if let hexColor = currentlySelectedCategory?.hexColor {
                topBackground.backgroundColor = .red
                //                topBackground.backgroundColor = UIColor.init(hexString: hexColor)
            }
            
            //            tableView.beginUpdates()
            
            dataSource.switchCategory(to: currentlySelectedCategory)
            updateRows()
            //            tableView.reloadSections(IndexSet(integersIn: 0...0), with: UITableViewRowAnimation.top)
            
            //            tableView.endUpdates()
        }
    }
    
    private(set) var tableView = sectorTableView()
    private lazy var noteMaker = NoteMakerController(withStorage: self.noteStorage)
    
    private var topbackgroundHeight: Constraint? = nil
    
    // Backgrounds to enable scrolling from missing cells
    fileprivate var bottomBackground = UIView()
    fileprivate var topBackground = UIView()
    fileprivate var transitioning = false
    fileprivate var beganScrollingAt: CGPoint!
    
    var nextNoteTable: NoteTableController?
    
    lazy var navHeight = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.dataSource = NoteDataSource(with: storage)
        self.categoryOfController = Categories._default
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
        tableView.delegate = self
        
        setupTableView()
    }
    
    deinit {
        removeObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        //        setupNavbar()
        addPullToRefresh()
        setColors(hasPins: dataSource.hasPinnedNotes)
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        updateColors()
        addSubviewAndConstraints()
        tableView.categoryReceiverDelegate = self
        addObservers()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateColors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    // MARK: - Methods
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            updateColors()
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeHandler()
        }
    }
    
    fileprivate func shakeHandler() {
        attemptRecoverDeletedNote()
    }
    
    private func attemptRecoverDeletedNote() {
        if let previouslyDeletedNote = noteStorage.undoDeletion() {
            dataSource.add(previouslyDeletedNote)
            playRecoveredSound()
            let insertionRow = dataSource.index(of: previouslyDeletedNote)
            tableView.insertRows(at: [insertionRow], with: .automatic)
        } else {
            playCouldNotRecoverSound()
        }
    }
    
    fileprivate func addSubviewAndConstraints() {
        view.addSubview(bottomBackground)
        view.addSubview(topBackground)
        view.addSubview(tableView)
        
        bottomBackground.isUserInteractionEnabled = false
        
        topBackground.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            self.topbackgroundHeight = make.height.equalTo(200).offset(0).constraint
        }
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
        }
        
        bottomBackground.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
        }
    }
    
    private func setPullToRefreshColor(for category: Category?) {
        guard let category = category else { return }
        
        noteMaker.update(for: category)
        if let hexColor = category.hexColor {
            UIView.animate(withDuration: 1) {
                self.topBackground.backgroundColor = UIColor.init(hexString: hexColor)
            }
            tableView.dg_setPullToRefreshFillColor(UIColor.init(hexString: hexColor))
        }
    }
    
    /// Sets the color of the pulldown wave to dijon if top note is pinned
    func updateColors() {
        let hasPins = dataSource.hasPinnedNotes
        setColors(hasPins: hasPins)
        //        checkContentSize()
    }
    
    func updateRows() {
        let noteCount = dataSource.notes.count
        let visibleRows = (tableView.visibleCells as! [NoteCell])
        let visibleCount = visibleRows.count
        
        for (i, cell) in visibleRows.enumerated() {
            if i < dataSource.notes.count {
                // tableview has visiblerows and datasource has notes. update existing cells
                let note = dataSource.notes[i]
                cell.updateWith(note: note)
            }
        }
        
        if visibleCount > noteCount {
            // Remove / hide some rows
            print("remove or hide some rows")
            for (i, cell) in visibleRows.enumerated() {
                
                var tempNote: Note? = nil
                
                if i < dataSource.notes.count {
                    tempNote = dataSource.notes[i]
                }
                
                cell.updateWith(note: tempNote)
            }
        }
        
    }
    
    func insertNewBlankCell() {
        print("would insert new blank cell")
        let noteCount = dataSource.notes.count
        let visibleRows = (tableView.visibleCells as! [NoteCell])
        let visibleCount = visibleRows.count
        
        let lastIP = dataSource.tableView(tableView, numberOfRowsInSection: 0) - 1
        
        print("got tablecount:" , lastIP)
        let ipToInsert = IndexPath(row: lastIP, section: 0)
        
        tableView.insertRows(at: [ipToInsert], with: .automatic)
    }
    
    func updateRows2() {
        
        // Reload rows funker ikke. Det blir choppy. Samme med reloadData
        
        //        tableView.reloadSections(IndexSet.init(integer: 0), with: .none)
        //        tableView.reloadData()
        
        // Plan 2
        // - if too many rows, hide them
        // - if too few rows, insert
        let noteCount = dataSource.notes.count
        let visibleRows = (tableView.visibleCells as! [NoteCell])
        let visibleCount = visibleRows.count
        
        //        tableView.beginUpdates()
        
        // MARK: DONE
        if visibleCount < noteCount {
            // Insert rows
            print("insert rows")
            
            var topI = 0
            
            for (i, cell) in visibleRows.enumerated() {
                if i < dataSource.notes.count {
                    // tableview has visiblerows and datasource has notes. update existing cells
                    let note = dataSource.notes[i]
                    cell.updateWith(note: note)
                    topI = i
                }
            }
            
            topI += 1
            while topI < noteCount {
                print("topi: \(topI) noteCount: \(noteCount)")
                let ip = IndexPath(row: topI, section: 0)
                print("print: tryna insert row at ip: ", ip)
                tableView.insertRows(at: [ip], with: .none)
                topI += 1
            }
        }
        
        // MARK: IF NEW TABLE HAS EQUAL NUMBER OF CELLS
        
        if visibleCount == noteCount {
            // just update
            print("just update")
            for (i, cell) in visibleRows.enumerated() {
                // tableview has visiblerows and datasource has notes. update existing cells
                let note = dataSource.notes[i]
                cell.updateWith(note: note)
            }
        }
        
        // FIXME: IF NEW TABLE HAS EQUAL NUMBER OF CELLS
        if visibleCount > noteCount {
            // Remove / hide some rows
            print("remove or hide some rows")
            for (i, cell) in visibleRows.enumerated() {
                
                var tempNote: Note? = nil
                
                if i < dataSource.notes.count {
                    tempNote = dataSource.notes[i]
                }
                
                cell.updateWith(note: tempNote)
            }
        }
    }
    
    private func setColors(hasPins: Bool) {
        switch hasPins {
        case true:
            tableView.dg_setPullToRefreshBackgroundColor(UIColor.dijon)
            topBackground.backgroundColor = .dijon
        case false:
            tableView.dg_setPullToRefreshBackgroundColor(UIColor.primary)
            topBackground.backgroundColor = .primary
        }
        if let hex = currentlySelectedCategory?.hexColor {
            topBackground.backgroundColor = UIColor.init(hexString: hex)
        }
        
        setBottomFooterColor()
    }
    
    private func setBottomFooterColor() {
        if let lastNote = dataSource.getLastNote() {
            if lastNote.isPinned {
                bottomBackground.backgroundColor = .dijon
            } else {
                bottomBackground.backgroundColor = .primary
            }
        } else {
            bottomBackground.backgroundColor = .primary
        }
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
        tableView.backgroundColor = .clear
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
            newNote.category = currentlySelectedCategory
            dataSource.add(newNote)
            playAcceptedSound()
            let insertionRow = dataSource.index(of: newNote)
    
            // NEW: Instead ov inserting into the tableview, switch on wether or not there are empty cells. if there are empty cells, just update them
            
            let noteCount = dataSource.notes.count
            let cellCount = tableView.visibleCells.count
            print("notecount: ", noteCount)
            print("cellCount: ", cellCount)
            
            // update cell
            
            if let cell = tableView.cellForRow(at: insertionRow) as? NoteCell {
                print("got cell")
                cell.updateWith(note: newNote)
                
                // new note is inserten as the first cell under any pinned cells, but its just updated, so any other notes are moved one down. update all of the cells underneath
                
                let visibleCells = tableView.visibleCells as! [NoteCell]
                
                guard let indexOfNewNote = visibleCells.index(of: cell) else {return}
                print("index of new cell is: ", indexOfNewNote)
                
                // update the cells undert he new cell

                print("printing visible cells")
                
                for c in visibleCells {
                    print("would update \(c.noteCellView.label.text)")
                    
                    // get cell number and then update it with the note from the matching notearray
                    
                    if let indexOfCell = tableView.indexPath(for: c) {
                        guard indexOfCell.row < dataSource.notes.count else {
                            self.tableView.dg_stopLoading()
                            return
                        }
                        c.updateWith(note: dataSource.notes[indexOfCell.row])
                    }
                }
                
                self.tableView.dg_stopLoading()
                
                for n in dataSource.notes {
                    print("note: ", n.content)
                }
            }
            
            // OLD
//            tableView.insertRows(at: [insertionRow], with: .automatic)
        } else {
            VibrationController.vibrate()
            playErrorSound()
            self.tableView.dg_stopLoading()
        }
    }
    
    // MARK: - Observer Methods
    
    private func addObservers(){
        // Observe when pulled enough to trigger
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPull),
                                               name: NSNotification.Name.DGPulledEnoughToTrigger, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPullAndRelease),
                                               name: NSNotification.Name.DGPulledEnoughToTriggerAndReleased,object: nil)
        
        // Observe size changed to update footer colors
        tableView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old, .prior], context: nil)
        
    }
    
    private func removeObservers() {
        tableView.removeObserver(self, forKeyPath: "contentSize")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DGPulledEnoughToTrigger, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DGPulledEnoughToTriggerAndReleased, object: nil)
    }
    
    // MARK: Handlers
    
    @objc func handleHardPull() {
        playPullSound()
    }
    
    @objc func handleHardPullAndRelease() {
        let todoTextField = noteMaker.noteMakerView.textField
        todoTextField.delegate = self
        todoTextField.becomeFirstResponder()
        playPullAndReleaseSound()
    }
    
    func handlePullToRefreshCompletion() {
        //
    }
}

extension NoteTableController: CategorySelectionReceiver {
    func handleReceiveCategory(_ category: Category) {
        // FIXME: make this one not be triggered if user they are scrolling below pulltorefresher
        currentlySelectedCategory = category
    }
}

// MARK: - Delegate

extension NoteTableController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        transitioning = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let overscroll = calculateOverScroll(for: scrollView)
        if overscroll > 100 && transitioning == false {
            transitioning = true
            VibrationController.vibrate()
        }
    }
    
    private func calculateOverScroll(for scrollView: UIScrollView) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let contentSize = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        
        if contentSize > screenHeight {
            // table is scrollable
            let overscroll = (contentSize - screenHeight - contentOffset) * -1
            
            if (overscroll * -1) >= 0 { topbackgroundHeight?.update(offset: overscroll * -1)}
            return overscroll
        } else {
            // table is not scrollable
            if (contentOffset * -1) >= 0 {
                topbackgroundHeight?.update(offset: contentOffset * -1)
            }
            return contentOffset
        }
    }
}

// MARK: - Custom transitions

extension NoteTableController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dismissNoteMaker()
        noteMaker.animateEndOfEditing()
        
        return true
    }
}

// MARK: - Sound

extension NoteTableController: SoundEffectPlayer {
    
    // FIXME: User multiple sounds when completing multiple tasks sequentially
    
    static var lastCompletion: Date? = nil
    static var completionStreak = 0
    
    func play(songAt url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    func playDoneSound() {
        play(songAt: URL.sounds.note._1)
    }
    
    func playPinSound() {
        play(songAt: URL.sounds.notification._8)
    }
    
    func playUnpinSound() {
        play(songAt: URL.sounds.notification._12)
    }
    
    func playAcceptedSound() {
        play(songAt: URL.sounds.done._5)
    }
    
    func playErrorSound() {
        play(songAt: URL.sounds.error._3)
    }
    
    func playPullAndReleaseSound() {
        play(songAt: URL.sounds.done._2)
    }
    
    func playPullSound() {
        play(songAt: URL.sounds.note._2)
    }
    
    func playRecoveredSound() {
        play(songAt: URL.sounds.done._9)
    }
    
    func playCouldNotRecoverSound() {
        play(songAt: URL.sounds.error._2)
    }
}

