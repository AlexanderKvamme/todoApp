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
    
    let textLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.custom(style: .bold, ofSize: .medium)
        lbl.textColor = .primaryContrast
        lbl.numberOfLines = 2
        return lbl
    }()
    
    let numberLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.custom(style: .bold, ofSize: .big)
        lbl.textAlignment = .center
        lbl.textColor = .primaryContrast
        lbl.numberOfLines = 1
        return lbl
    }()
    
    // MAKR: - Initializers
    
    override init(frame: CGRect) {
        self.textLabel.text = "TEMP"
        super.init(frame: frame)
        
        backgroundColor = .primary
        
//        addSubviewsAndConstraints()
        addSubviewsWithoutNumber() // FIXME: Improve this default
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAKR: Methods
    
    private func updateSubviewsAndConstraints(for note: Note?) {
        guard let note = note else {
            addSubviewsWithoutNumber()
            print("note was nil - removing numberlabel")
            return
        }
        
        if note.isNumbered() {
            addSubviewsWithNumber()
            numberLabel.text = String(note.number)
            textLabel.textAlignment = .left
        } else {
            textLabel.textAlignment = .center
            addSubviewsWithoutNumber()
        }
    }
    
    /// Sets up cell no not have a numberindicator to the left
    private func addSubviewsWithoutNumber() {
        textLabel.removeFromSuperview()
        numberLabel.removeFromSuperview()
        
        addSubview(textLabel)
        textLabel.sizeToFit()
        
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.leftMargin)
            make.right.equalTo(snp.rightMargin)
            make.top.equalTo(snp.top)
            make.bottom.equalTo(snp.bottom)
        }
    }

    private func addSubviewsWithNumber() {
        textLabel.removeFromSuperview()
        numberLabel.removeFromSuperview()
        
        addSubview(textLabel)
        addSubview(numberLabel)
        
        textLabel.sizeToFit()
        
        numberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.leftMargin)
            make.top.equalTo(snp.topMargin)
            make.bottom.equalTo(snp.bottom)
            make.width.equalTo(40)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(numberLabel.snp.right).offset(8)
            make.right.equalTo(snp.rightMargin)
            make.top.equalTo(snp.top)
            make.bottom.equalTo(snp.bottom)
        }
    }

    func updateWith(note: Note?) {
        guard let note = note else {
            textLabel.text = ""
            backgroundColor = .primary
            updateSubviewsAndConstraints(for: nil)
            return
        }
        
        textLabel.text = note.getText()
        updateSubviewsAndConstraints(for: note)
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

