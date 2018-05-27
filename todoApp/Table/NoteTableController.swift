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
            dataSource.switchCategory(to: currentlySelectedCategory)
            updateRows()
        }
    }
    
    let leftTest = UIView()
    let rightTest = UIView()
    
    private(set) var tableView = sectorTableView()
    private lazy var noteMaker = NoteMakerController(withStorage: self.noteStorage)
    
    private var topbackgroundHeight: Constraint? = nil
    
    // Backgrounds to enable scrolling from missing cells
    fileprivate var bottomBackground = UIView()
    fileprivate var topBackground = UIView()
    fileprivate var transitioning = false
    fileprivate var beganScrollingAt: CGPoint!
    
    var shouldSwitchCategoryOnPull = true
    
    var tableViewShouldBeEditable = true {
        didSet {
            print("--didset tableViewShouldBeEditable: ", tableViewShouldBeEditable)
        }
    }
    
    lazy var navHeight = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.dataSource = NoteDataSource(with: storage)
        self.categoryOfController = Categories._default
        self.currentlySelectedCategory = Categories._default
        
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
        noteMaker.delegate = self
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        updatePinColors()
        addSubviewAndConstraints()
        tableView.categoryReceiverDelegate = self
        addObservers()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    // MARK: - Methods
    
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
        guard let catCol = currentlySelectedCategory?.hexColor else {
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
        guard let currentCategory = currentlySelectedCategory else { return }
        
        UIView.animate(withDuration: Constants.animation.categorySwitchLength) {
            // FIXME: Use the category color to generate pin color
            let darkColor = self.getDarkerColor(for: currentCategory)
            
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
        guard let hexColor = currentlySelectedCategory?.hexColor else { fatalError("must have initiali color") }
        
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
    
    private func setTableEditable(_ b: Bool) {
        tableViewShouldBeEditable = b
    }
    
    // MARK: Handlers
    
    @objc func handlePullStarted() {
        print("pull started")
    }
    
    @objc func handlePullEnded() {
        print("pull ended")
    }
    
    @objc func handleHardPull() {
        print("playing hard pull sound")
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

        print("received cat")
        guard shouldSwitchCategoryOnPull else { return }
        
        currentlySelectedCategory = category
        
        guard let index = Categories.all.index(of: category) else { return }
        
        switch index {
        case 0:
            playCategoryOneSound()
        case 1:
            playCategoryTwoSound()
        case 2:
            playCategoryThreeSound()
        case 3:
            playCategoryFourSound()
        case 4:
            playCategoryFiveSound()
        default:
            return
        }
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
            adjustVolume(for: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    private func adjustVolume(for url: URL) {
        let lowSounds = [URL.sounds.categoryChange._1, URL.sounds.categoryChange._2, URL.sounds.categoryChange._3, URL.sounds.categoryChange._4, URL.sounds.categoryChange._5]
        if lowSounds.contains(url) {
            audioPlayer.volume = 0.05
    } else {
            audioPlayer.volume = 1
        }
    }
    
    // 5 rising notes
    
    func playCategoryOneSound() {
        play(songAt: URL.sounds.categoryChange._1)
    }
    
    func playCategoryTwoSound() {
        play(songAt: URL.sounds.categoryChange._2)
    }
    
    func playCategoryThreeSound() {
        play(songAt: URL.sounds.categoryChange._3)
    }
    
    func playCategoryFourSound() {
        play(songAt: URL.sounds.categoryChange._4)
    }
    
    func playCategoryFiveSound() {
        play(songAt: URL.sounds.categoryChange._5)
    }
    
    // Other sounds
    
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

