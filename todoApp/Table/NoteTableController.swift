//
//  MainViewController.swift
//  todoApp
//
//  Created by Alexander Kvamme on 20/02/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import SwipeCellKit
import SnapKit
import AVFoundation

// FIXME: Lots of switch statements. Consider the state patternu

// MARK: - Custom Notifications

enum Globals {
    static var screenHeight = UIScreen.main.bounds.height
    static var screenWidth = UIScreen.main.bounds.width
}

/// Contains a tableview with a pull to refresh
class NoteTableController: UIViewController, UITableViewDelegate {
    
    private var audioPlayer: AVAudioPlayer?
    private let noteStorage: NoteStorage
    private var dataSource: NoteDataSource
    private let categoryOfController: Category
    private var currentlySelectedCategory: Category {
        didSet {
            // FIMXE: refactor
            setPullToRefreshColor(for: currentlySelectedCategory)
            dataSource.switchCategory(to: currentlySelectedCategory)
            updateRows()
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
    fileprivate var isPulling = false
    
    var shouldSwitchCategoryOnPull = true
    var tableViewShouldBeEditable = true // table is disabled when making notes
    
    lazy var navHeight = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.dataSource = NoteDataSource(with: storage)
        self.categoryOfController = Categories.firstCategory
        self.currentlySelectedCategory = Categories.firstCategory
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
        dataSource.tableView = tableView
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
        noteMaker.delegate = self
        noteMaker.noteMakerView.textField.delegate = self
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        updatePinColors()
        addSubviewAndConstraints()
        tableView.categoryReceiverDelegate = self
        addObservers()
        tableView.reloadData()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    // MARK: - Methods
    
    fileprivate func presentCategoryEditor() {
        let editorController = CategoryEditorController(for: currentlySelectedCategory)
        editorController.delegate = self
        tableView.dg_stopLoading()
        navigationController?.pushViewController(editorController, animated: true)
    }
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            updatePinColors()
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
        return
        
        // FIXME: - Go over to updateing cells manually instead of inserting/deleting
//        if let previouslyDeletedNote = noteStorage.undoDeletion() {
//            dataSource.add(previouslyDeletedNote)
//            playRecoveredSound()
//            let insertionRow = dataSource.index(of: previouslyDeletedNote)
//            tableView.insertRows(at: [insertionRow], with: .automatic)
//        } else {
//            playCouldNotRecoverSound()
//        }
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
        guard let hexColor = category.hexColor else { return }
        noteMaker.updateLabel(for: category)
        
        UIView.animate(withDuration: Constants.animation.categorySwitchLength) {
            self.topBackground.backgroundColor = UIColor.init(hexString: hexColor)
            self.tableView.dg_setPullToRefreshFillColor(UIColor.init(hexString: hexColor))
        }
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
            for (i, cell) in visibleRows.enumerated() {
                cell.updateWith(note: (i < dataSource.notes.count) ? dataSource.notes[i] : nil)
            }
        }
    }
    
    func insertNewBlankCell() {
        let lastIP = dataSource.tableView(tableView, numberOfRowsInSection: 0) - 1
        let ipToInsert = IndexPath(row: lastIP, section: 0)
        
        tableView.insertRows(at: [ipToInsert], with: .automatic)
    }
    
    func getCategoryColor(for category: Category) -> UIColor {
        guard let catCol = category.hexColor else {
            fatalError("Should have color. Add Default")
        }
        return UIColor(hexString: catCol)
    }
    
    func getCurrentCategoryColor() -> UIColor {
        guard let catCol = currentlySelectedCategory.hexColor else {
            fatalError("Should have color. Add Default")
        }
        return UIColor(hexString: catCol)
    }
    
    func getDarkerColor(for category: Category) -> UIColor {
        guard let catCol = category.hexColor else {
            fatalError("Should have color. Add Default")
        }
        return UIColor(hexString: catCol).darker(by: 10)
    }
    
    /// Sets the color of the pulldown wave to dijon if top note is pinned
    func updatePinColors() {
        UIView.animate(withDuration: Constants.animation.categorySwitchLength) {
            let darkColor = self.getDarkerColor(for: self.currentlySelectedCategory)
            
            switch self.dataSource.hasPinnedNotes {
            case true:
                self.tableView.dg_setPullToRefreshBackgroundColor(darkColor)
                self.topBackground.backgroundColor = darkColor
            case false:
                self.tableView.dg_setPullToRefreshBackgroundColor(UIColor.primary)
                self.topBackground.backgroundColor = .primary
            }
            
            self.setBottomFooterColor()
        }
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
    func addPullToRefresh() {
        guard let hexColor = currentlySelectedCategory.hexColor else { fatalError("must have initial color") }
        
        let newCol = UIColor(hexString: hexColor)
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.handlePullToRefreshCompletion()
            }, loadingView: noteMaker.view as? DGElasticPullToRefreshLoadingView)
        tableView.dg_setPullToRefreshFillColor(newCol)
    }
    
    /// Make note if it has text and has not exceeded maximum cellcount
    func dismissNoteMaker() {
        if dataSource.isFull {
            indicateError()
            return
        }
        
        guard let newNote = noteMaker.makeNoteFromInput() else {
            indicateError()
            return
        }
        
        // insert new note as a cell
        newNote.category = currentlySelectedCategory
        // FIXME: Set itsn umber to be the first one under pinned ones
        newNote.number = 0 // Int16(currentlySelectedCategory.numberedNotes().count) // Will be added under pin
        newNote.category!.incrementNumbers()
        
        dataSource.add(newNote)
        playAcceptedSound()
        
        let insertionRow = dataSource.index(of: newNote)
        
        // Instead of inserting into the tableview, switch on wether or not there are empty cells. if there are empty cells, just update them
        if let cell = tableView.cellForRow(at: insertionRow) as? NoteCell {
            cell.updateWith(note: newNote)
            // new note is inserted as the first cell under any pinned cells. update all of the cells underneath
            let visibleCells = tableView.visibleCells as! [NoteCell]
            
            for cell in visibleCells {
                if let indexOfCell = tableView.indexPath(for: cell), indexOfCell.row < dataSource.notes.count {
                    cell.updateWith(note: dataSource.notes[indexOfCell.row])
                }
            }
            self.tableView.dg_stopLoading()
        }
    }
    
    func indicateError() {
        self.tableView.dg_stopLoading()
        VibrationController.vibrate()
        self.playErrorSound()
    }
    
    // MARK: - Observer Methods
    
    private func addObservers(){
        // Observe when pulled enough to trigger
        NotificationCenter.default.addObserver(self, selector: #selector(handlePullStarted),
                                               name: NSNotification.Name.DGPullStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePullEnded),
                                               name: NSNotification.Name.DGPullEnded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPull),
                                               name: NSNotification.Name.DGPulledEnoughToTrigger, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPullAndRelease),
                                               name: NSNotification.Name.DGPulledEnoughToTriggerAndReleased,object: nil)
        
        // Observe size changed to update footer colors
        tableView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old, .prior], context: nil)
    }
    
    private func removeObservers() {
        tableView.removeObserver(self, forKeyPath: "contentSize")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DGPullStarted, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DGPullEnded, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DGPulledEnoughToTrigger, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.DGPulledEnoughToTriggerAndReleased, object: nil)
    }
    
    // MARK: Handlers
    
    @objc func handlePullStarted() {
        isPulling = true
        noteMaker.updateLabel(for: currentlySelectedCategory)
    }
    
    @objc func handlePullEnded() {
        isPulling = false
    }
    
    @objc func handleHardPull() {
        playPullSound()
    }
    
    @objc func handleHardPullAndRelease() {
        isPulling = false
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

        guard shouldSwitchCategoryOnPull else { return }
        
        currentlySelectedCategory = category
        
        guard let index = Categories.all.index(of: category) else { return }
        
        playCategorySound(index)
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
        
        shouldSwitchCategoryOnPull = true
        tableViewShouldBeEditable = true
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let res = isPulling ? false : true
        log.info("textFieldShouldBeginEditing \(res)")
        if isPulling {
            presentCategoryEditor()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.info("did begin editing")
        shouldSwitchCategoryOnPull = false
        tableViewShouldBeEditable = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        log.info("did end editing")
        textField.resignFirstResponder()
    }
}

// MARK: - Sound

extension NoteTableController: SoundEffectPlayer {
    
    static var lastCompletion: Date = Date()
    static var completionStreak = 1
    
    func play(songAt url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            adjustVolume(for: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print(error)
        }
    }
    
    private func adjustVolume(for url: URL) {
        guard let audioPlayer = audioPlayer else { return }
        
        let categoryChangeSounds = [URL.sounds.categoryChange._1, URL.sounds.categoryChange._2, URL.sounds.categoryChange._3, URL.sounds.categoryChange._4, URL.sounds.categoryChange._5]
        let sequentialCompletionSounds = [URL.sounds.mallet._1, URL.sounds.mallet._2, URL.sounds.mallet._3, URL.sounds.mallet._4, URL.sounds.mallet._5]
        
        if categoryChangeSounds.contains(url) {
            audioPlayer.volume = 0.07
        } else if sequentialCompletionSounds.contains(url) {
            audioPlayer.volume = 0.1
        } else {
            audioPlayer.volume = 0.7
        }
    }
    
    // MARK: Category sounds
    
    func playCategorySound(_ catIndex: Int) {
        switch catIndex {
        case 0:
            play(songAt: URL.sounds.categoryChange._1)
        case 1:
            play(songAt: URL.sounds.categoryChange._2)
        case 2:
            play(songAt: URL.sounds.categoryChange._3)
        case 3:
            play(songAt: URL.sounds.categoryChange._4)
        case 4:
            play(songAt: URL.sounds.categoryChange._5)
        default:
            fatalError()
        }
    }

    // MARK: Other sounds
    
    /// Play sound depending on its in close succession to the last completion, and play corrent sou
    func playDoneSound() {
        
        let now = Date()
        let lastCompletion = NoteTableController.lastCompletion
        let timePassed = now.timeIntervalSince1970 - lastCompletion.timeIntervalSince1970
        
        if timePassed < 3 {
            switch NoteTableController.completionStreak {
            case 1:
                NoteTableController.completionStreak = 2
                play(songAt: URL.sounds.mallet._2)
            case 2:
                NoteTableController.completionStreak = 3
                play(songAt: URL.sounds.mallet._3)
            case 3:
                NoteTableController.completionStreak = 4
                play(songAt: URL.sounds.mallet._4)
            case 4:
                NoteTableController.completionStreak = 5
                play(songAt: URL.sounds.mallet._5)
            default:
                NoteTableController.completionStreak = 5
                play(songAt: URL.sounds.mallet._5)
            }
        } else {
            NoteTableController.completionStreak = 1
            play(songAt: URL.sounds.mallet._1)
        }
        NoteTableController.lastCompletion = Date()
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
        
//        print("audioplayer:", audioPlayer)
//        if audioPlayer.isPlaying == false {
//            self.play(songAt: URL.sounds.note._2)
//        }
        
        // My fix but shows warning
        if audioPlayer?.isPlaying == false {
            self.play(songAt : URL.sounds.note._2)
            }
    }
    
    func playRecoveredSound() {
        // FIXME: Find sound after new implementation
//        play(songAt: URL.sounds.done._9)
    }
    
    func playCouldNotRecoverSound() {
        play(songAt: URL.sounds.error._2)
    }
}

