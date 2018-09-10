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
class NoteTableController: UIViewController {
    
    private var audioPlayer: AVAudioPlayer?
    private let noteStorage: NoteStorage
    private var dataSource: NoteDataSource
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
    fileprivate var overlayView = UIView()
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
        self.currentlySelectedCategory = Categories.firstCategory
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
        dataSource.tableView = tableView
        
        overlayView.alpha = 0
        overlayView.backgroundColor = .black
        overlayView.isUserInteractionEnabled = false
        
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
        addIt()
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
        view.addSubview(overlayView)
        
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
        
        overlayView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
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
        tableView.backgroundColor = .clear
        tableView.allowsSelection = true
        tableView.delegate = self
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
        log.warning("new note got category: \(currentlySelectedCategory)")
        // FIXME: Set itsn umber to be the first one under pinned ones
        //newNote.number = 0
        newNote.number = currentlySelectedCategory.getHighestNumber() + 1
        print("making this notes new number: ", newNote.number)
        //newNote.category!.incrementUnpinnedNumbers()
        
        DatabaseFacade.saveContext()
        
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
        }
        self.tableView.dg_stopLoading()
    }
    
    func indicateError() {
        tableView.dg_stopLoading()
        VibrationController.vibrate()
        playErrorSound()
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
        
        if dataSource.isFull {
            indicateError()

            dataSource.stopTrackingPull()
            dataSource.startTtrackingPull()
            
            return
        }
        
        let todoTextField = noteMaker.noteMakerView.textField
        todoTextField.delegate = self
        todoTextField.becomeFirstResponder()
        playPullAndReleaseSound()
    }
    
    func handlePullToRefreshCompletion() {
        //
    }
    
    func animateBackground(visible: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = visible ? 1 : 0
        }
    }
}

extension NoteTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < currentlySelectedCategory.notes!.count else {
            log.warning("tapped empty note")
            // FIXME: Let user edit note directly if tapping first avaiable note
            return
        }
        
        presentDetailedNoteController(for: dataSource.notes[indexPath.row])
    }
    
    func presentDetailedNoteController(for note: Note) {
        let detailedController = NotePreviewController(with: note, on: view)
        detailedController.modalPresentationStyle = .overCurrentContext // Funker litt
        detailedController.owner = self
        
        animateBackground(visible: true)
        
        DispatchQueue.main.async {
            self.present(detailedController, animated: true) {
                print("done presenting")
            }
        }
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


// MARK: - Move cells

extension NoteTableController {

    func addIt() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        tableView.addGestureRecognizer(longpress)
    }

    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        switch state {
        case UIGestureRecognizerState.began:
            dataSource.stopTrackingPull() // FIXME: Move to Table
            tableView.isScrollEnabled = false
            
            guard indexPath!.row < dataSource.notes.count else {
                log.warning("tryna move blank cell. Show animation making view red or something")
                // Disable gesture to prevent moving cell
                gestureRecognizer.isEnabled = false
                gestureRecognizer.isEnabled = true
                
                tableView.isScrollEnabled = true
                return
            }
            
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = (tableView.cellForRow(at: indexPath!))!

                // hide cell number
                if let cell = tableView.cellForRow(at: indexPath!) {
                    let castedCell = (cell as! NoteCell)
                    if castedCell.noteCellView.isNumbered {
                        castedCell.noteCellView.numberLabel.alpha = 0
                    }
                }
                
                My.cellSnapshot  = snapshotOfCell(cell)
                var center = cell.center
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell.alpha = 1
                            })
                        } else {
                            cell.isHidden = true
                        }
                    }
                })
            }
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    guard indexPath!.row < dataSource.notes.count else {
                        return
                    }
                    
                    dataSource.swap(Path.initialIndexPath!.row, and: indexPath!.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    
                    let fromIP = Path.initialIndexPath!
                    let toIP = indexPath!
                    tableView.reloadRows(at: [fromIP, toIP], with: .automatic)
                    
                    Path.initialIndexPath = indexPath
                }
            }
        case .ended:
            dataSource.startTtrackingPull()
            tableView.isScrollEnabled = true
            fallthrough
        default:
            if Path.initialIndexPath != nil {
                let cell = (tableView.cellForRow(at: Path.initialIndexPath!))!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell.isHidden = false
                    cell.alpha = 0.0
                }
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
    }

    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)//CGSize(width: -5.0, height: 0.0
            cellSnapshot.layer.shadowRadius = 5.0
            cellSnapshot.layer.shadowOpacity = 0.4
            return cellSnapshot
    }
    /*
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return itemsArray.count
     }
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
     cell.textLabel?.text = itemsArray[indexPath.row]
     cell.textLabel?.textColor? = UIColor.white
     return cell
     }
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     tableView.deselectRow(at: indexPath, animated: false)
     }
     */
}

