//
//  NoteCellView.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


final class NoteCellView: UIView {

    // MARK: - Properties
    
    static let defaultHeight: CGFloat = Constants.cells.defaultHeight
    static let defaultWidth: CGFloat = Constants.screen.width
    
    // Computed properties
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.custom(style: .bold, ofSize: .big)
        lbl.textColor = .primaryContrast
        return lbl
    }()
    
    // MAKR: - Initializers
    
    override init(frame: CGRect) {
        self.label.text = "TEMP"
        super.init(frame: frame)
        
        backgroundColor = .primary
        
        addSubviewsAndConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAKR: Methods
    
    private func addSubviewsAndConstraints() {
        addSubview(label)
        
        label.sizeToFit()
        
        label.snp.makeConstraints { (make) in
            make.center.equalTo(snp.center)
        }
    }
    
    func updateWith(note: Note) {
        label.text = note.getText()
    }
}

