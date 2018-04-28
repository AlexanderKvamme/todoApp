//
//  SectorTableView.swift
//  todoApp
//
//  Created by Alexander K on 28/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class sectorTableView: UITableView, UIGestureRecognizerDelegate {
    
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
            let sectorLength = Globals.screenWidth/CGFloat(sectorCount)
            let categoryIndex = Int(floor(x/sectorLength))
            print("category:", Categories.all[categoryIndex].name!)
        default:
            break
        }
    }
    
    // MARK: UIGestureRecognizerDelegate conformance
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

