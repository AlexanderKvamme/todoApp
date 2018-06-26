//
//  SectorTableView.swift
//  todoApp
//
//  Created by Alexander K on 28/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


/// Lets a category be selected based on where the user has his finger horizontally
protocol CategorySelectionReceiver: class {
    func handleReceiveCategory(_ category: Category)
}

/// TableView which also tracks whoch horizontal sector users finger is panning in and delegates this information to a CategorySelectionReceiver
class sectorTableView: UITableView, UIGestureRecognizerDelegate {
    
    // MARK: - Properties

    private var initialY: CGFloat = 0 // FIXME: Replace with the hasPulledHard notification
    
    weak var categoryReceiverDelegate: CategorySelectionReceiver? = nil
    
    private var recentlySelectedCategory: Category = Categories.firstCategory {
        willSet {
            guard newValue != recentlySelectedCategory else { return }
            categoryReceiverDelegate?.handleReceiveCategory(newValue)
        }
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero, style: UITableViewStyle.plain)
        
        addPanGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(yourPan(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func yourPan(_ gesture: UIPanGestureRecognizer) {
        let sectorCount = Categories.count
        let x = gesture.location(in: self).x
        let y = gesture.location(in: self).y
        
        switch gesture.state {
            
        case .began:
            initialY = y
            
        case .changed:
            guard y > 0 else {return}
            
            let sectorLength = Globals.screenWidth/CGFloat(sectorCount)
            let categoryIndex = Int(floor(x/sectorLength))
            if (y - initialY) < 100 {
                break
            }
            recentlySelectedCategory = Categories.all[categoryIndex]
        default:
            break
        }
    }
    
    // MARK: UIGestureRecognizerDelegate conformance
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // FIXME: disable swiping when panning
        return true
    }
}

