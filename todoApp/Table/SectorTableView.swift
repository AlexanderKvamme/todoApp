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
    
    weak var categoryReceiverDelegate: CategorySelectionReceiver? = nil
    
    private var recentlySelectedCategory: Category = Categories._default {
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
        
        switch gesture.state {
        case .changed:
            let x = gesture.location(in: self).x
            guard x > 0 else {return}
            let sectorLength = Globals.screenWidth/CGFloat(sectorCount)
            let categoryIndex = Int(floor(x/sectorLength))
            recentlySelectedCategory = Categories.all[categoryIndex]
        default:
            break
        }
    }
    
    // MARK: UIGestureRecognizerDelegate conformance
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

