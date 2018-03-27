//
//  NoteCellView.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


final class NoteCellView: UIView {

    let label = UILabel()
    
    // MAKR: - Initializers
    
    override init(frame: CGRect) {
        self.label.text = "TEMP"
        super.init(frame: frame)
        
        addSubviewsAndConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAKR: Methods
    
    func addSubviewsAndConstraints() {
        addSubview(label)
        
        
    }
}

