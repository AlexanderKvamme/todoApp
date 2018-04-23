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

enum globals {
    static var screenHeight = UIScreen.main.bounds.height
    static var screenWidth = UIScreen.main.bounds.height
}


/// Contains a tableview with a pull to refresh
class NoteTableController: UIViewController, UITableViewDelegate{
    private var audioPlayer = AVAudioPlayer()
    private let noteStorage: NoteStorage
    private let dataSource: NoteDataSource
    private(set) var tableView = UITableView()
    private lazy var noteMaker = NoteMakerController(withStorage: self.noteStorage)
    
    fileprivate var bottomView = UIView()
    fileprivate var heightConstraint: Constraint? = nil
    fileprivate var initialFooterOffset: CGFloat = 0
    fileprivate var transitioning = false
    
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
        
        initialFooterOffset = calculateFooterHeight(for: tableView)
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
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeHandler()
        }
    }
    
    fileprivate func shakeHandler() {
        print("handle shake")
    }
    
    fileprivate func checkContentSize() {
        let screenHeight = UIScreen.main.bounds.height
        let contentSize = tableView.contentSize.height
        
        if contentSize < screenHeight {
            bottomView.backgroundColor = .primary
        } else {
            bottomView.backgroundColor = .green
        }
    }
    
    fileprivate func addSubviewAndConstraints() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.width.equalTo(view.snp.width)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.width.equalTo(view.snp.width)
            self.heightConstraint = make.height.equalTo(0).offset(initialFooterOffset).constraint
        }
    }
    
    /// Sets the color of the pulldown wave to dijon if top note is pinned
    func updateColors() {
        let hasPins = dataSource.hasPinnedNotes
        setColors(hasPins: hasPins)
        checkContentSize()
    }
    
    private func setColors(hasPins: Bool) {
        switch hasPins {
        case true:
            tableView.dg_setPullToRefreshBackgroundColor(UIColor.dijon)
            tableView.backgroundColor = UIColor.dijon
        case false:
            tableView.dg_setPullToRefreshBackgroundColor(UIColor.primary)
            tableView.backgroundColor = UIColor.primary
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newFooterHeight = calculateFooterHeight(for: scrollView)
        
        if newFooterHeight > 100 && transitioning == false {
            print("Would trigger transition")
            transitioning = true
            animateToNextController(from: bottomView)
        }
        
        heightConstraint?.update(offset: newFooterHeight)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        heightConstraint?.update(offset: calculateFooterHeight(for: scrollView))
    }
    
    private func calculateFooterHeight(for scrollView: UIScrollView) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let contentSize = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        let bottomViewHeight = (contentSize - screenHeight - contentOffset) * -1

        return bottomViewHeight
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
}

