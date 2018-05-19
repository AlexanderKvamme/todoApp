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
        lbl.font = UIFont.custom(style: .bold, ofSize: .medium)
        lbl.textAlignment = .center
        lbl.textColor = .primaryContrast
        lbl.numberOfLines = 2
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
            make.left.equalTo(snp.leftMargin)
            make.right.equalTo(snp.rightMargin)
            make.top.equalTo(snp.top)
            make.bottom.equalTo(snp.bottom)
        }
    }
    
    func updateWith(note: Note?) {
        guard let note = note else {
            label.text = ""
            backgroundColor = .primary
            return
        }
        
        label.text = note.getText()
        updateBackgroundColor(for: note, animated: true)
    }
    
    private func updateBackgroundColor(for note: Note, animated: Bool) {

        switch animated {
        case false:
            if note.isPinned {
                if let hex = note.category?.hexColor {
                    let newCol = UIColor.init(hexString: hex).darker(by: 10)
                    backgroundColor = newCol
                }
            } else {
                backgroundColor = .primary
            }
        case true:
            UIView.animate(withDuration: Constants.animation.categorySwitchLength) {
                if note.isPinned {
                    if let hex = note.category?.hexColor {
                        let newCol = UIColor.init(hexString: hex).darker(by: 10)
                        self.backgroundColor = newCol
                    }
                } else {
                    self.backgroundColor = .primary
                }
            }
        }
    }
}

