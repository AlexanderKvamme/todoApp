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
    private let dataSource: NoteDataSource
    
    private(set) var tableView = sectorTableView()
    private lazy var noteMaker = NoteMakerController(withStorage: self.noteStorage)
    
    private var topbackgroundHeight: Constraint? = nil
    
    // Backgrounds to enable scrolling from missing cells
    fileprivate var bottomBackground = UIView()
    fileprivate var topBackground = UIView()
    fileprivate var transitioning = false
    fileprivate var beganScrollingAt: CGPoint!
    
    lazy var navHeight = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    // MARK: - Initializers
    
    init(with storage: NoteStorage) {
        self.noteStorage = storage
        self.dataSource = NoteDataSource(with: storage)
        
        super.init(nibName: nil, bundle: nil)

        dataSource.delegate = self
        tableView.delegate = self
        addObservers()
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
        setupTableView()
        addPullToRefresh()
        setColors(hasPins: dataSource.hasPinnedNotes)
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTableView()
        updateColors()
        addSubviewAndConstraints()
        updateColors()
    }

    override func viewDidAppear(_ animated: Bool) {
        updateColors()
    }
    
    // MARK: - Methods
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            updateColors()
//            let newFooterHeight = calculateFooterHeight(for: tableView)
//            self.heightConstraint?.update(offset: newFooterHeight)
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
    
    /// Sets the color of the pulldown wave to dijon if top note is pinned
    func updateColors() {
        let hasPins = dataSource.hasPinnedNotes
        setColors(hasPins: hasPins)
//        checkContentSize()
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
            dataSource.add(newNote)
            playAcceptedSound()
            let insertionRow = dataSource.index(of: newNote)
            tableView.insertRows(at: [insertionRow], with: .automatic)
            self.tableView.dg_stopLoading()
        } else {
            VibrationController.vibrate()
            playErrorSound()
            self.tableView.dg_stopLoading()
        }
    }
    
    // MARK: - Transition
    
    func animateToNextController(from view: UIView) {
//        let frame = view.frame
        print("would transition from: ", view.frame)
        VibrationController.vibrate()
    }
    
    // MARK: - Observer Methods
    
    private func addObservers(){
        // Observe size changed to update footer colors
        tableView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old, .prior], context: nil)
        
        // Observe when pulled enough to trigger
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPull), name: .DGPulledEnoughToTrigger, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHardPullAndRelease), name: .DGPulledEnoughToTriggerAndReleased,object: nil)
    }
    
    private func removeObservers() {
        tableView.removeObserver(self, forKeyPath: "contentSize")
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

// MARK: - Delegate

extension NoteTableController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        transitioning = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let overscroll = calculateOverScroll(for: scrollView)
        if overscroll > 100 && transitioning == false {
            print("Would trigger transition")
            transitioning = true
            VibrationController.vibrate()
//            animateToNextController(from: footerView)
        }
    }
    
    private func calculateOverScroll(for scrollView: UIScrollView) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let contentSize = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y

        if contentSize > screenHeight {
            // table is scrollable
            let overscroll = (contentSize - screenHeight - contentOffset) * -1
            
            if (overscroll * -1) >= 0 {
                topbackgroundHeight?.update(offset: overscroll * -1)
            }
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

