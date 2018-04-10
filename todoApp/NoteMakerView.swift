//
//  NoteMakerView.swift
//  todoApp
//
//  Created by Alexander K on 02/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import DGElasticPullToRefresh


/// Small view that is basically a pretty textfield to be shown over a new cell before it has content
class NoteMakerView: DGElasticPullToRefreshLoadingView {
    
    static var height: CGFloat = {
       return NoteCellView.defaultHeight
    }()
    
    static var width: CGFloat = {
        return Constants.screen.width
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .green
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

