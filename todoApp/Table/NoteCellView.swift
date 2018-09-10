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
    
    private var currentNote: Note?
    private var triangleView = TriangleView(frame: CGRect(x: 0, y: 0, width: Constants.screen.width, height: NoteCellView.defaultHeight))
    
    // Computed properties
    
    let textLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.custom(style: .bold, ofSize: .medium)
        lbl.textAlignment = .left
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
        lbl.alpha = 0.2
        return lbl
    }()
    
    let cellMoveIcon: UIImageView = {
        let img = UIImage.moveCellIcon
        let iv = UIImageView(image: img)
        iv.tintColor = UIColor.primary.darker()
        
        return iv
    }()
    
    // MAKR: - Initializers
    
    override init(frame: CGRect) {
        self.textLabel.text = "TEMP"
        super.init(frame: frame)
        
        backgroundColor = .primary
        
        addSubviewsWithoutNumber() // FIXME: Improve this default
        
//        addTriangleView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MAKR: Methods
    
    private func addTriangleView() {
        clipsToBounds = false
        addSubview(triangleView)
    }
    
    private func updateSubviewsAndConstraints(for note: Note?) {
        currentNote = note
        guard let note = note else {
            addSubviewsWithoutNumber()
            return
        }

        if note.category!.isNumbered {
            addSubviewsWithNumber()
            numberLabel.text = String(note.number)
        } else {
            addSubviewsWithoutNumber()
        }
    }
    
    /// Sets up cell no not have a numberindicator to the left
    private func addSubviewsWithoutNumber() {
        textLabel.removeFromSuperview()
        numberLabel.removeFromSuperview()
        cellMoveIcon.removeFromSuperview()
        
        addSubview(textLabel)
        textLabel.sizeToFit()
        
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.leftMargin).offset(18)
            make.right.equalTo(snp.rightMargin)
            make.top.equalTo(snp.top)
            make.bottom.equalTo(snp.bottom)
        }
    }

    private func addSubviewsWithNumber() {
        let iconsize: CGFloat = 20
        
        textLabel.removeFromSuperview()
        numberLabel.removeFromSuperview()
        cellMoveIcon.removeFromSuperview()
        
        addSubview(textLabel)
        addSubview(numberLabel)
        addSubview(cellMoveIcon)

        textLabel.sizeToFit()
        
        numberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.leftMargin)
            make.top.equalTo(snp.topMargin)
//            make.bottom.equalTo(snp.bottom)
            make.width.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        cellMoveIcon.snp.makeConstraints { (make) in
            make.right.equalTo(snp.rightMargin).offset(-16)
            make.centerY.equalTo(snp.centerY)
            
            make.width.equalTo(iconsize)
            make.height.equalTo(iconsize)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(numberLabel.snp.right).offset(8)
            make.right.equalTo(cellMoveIcon.snp.left).offset(-8)
            make.centerY.equalToSuperview()
//            make.top.equalTo(snp.top).offset(8)
//            make.bottom.equalTo(snp.bottom)
        }
    }

    func updateWith(note: Note?) {
        self.currentNote = note
        guard let note = note else {
            textLabel.text = ""
            backgroundColor = .primary
            updateSubviewsAndConstraints(for: nil)
            updateBackground(for: nil, animated: true)
            return
        }
        
        textLabel.text = note.getText()
        updateSubviewsAndConstraints(for: note)
        updateBackground(for: note, animated: true)
    }
    
    func animateToNewNumber() {
        guard let note = currentNote else {
            return
        }
        
        numberLabel.text = String(note.number)
    }
    
    private func updateBackground(for note: Note?, animated: Bool) {
        guard let note = note else {
            triangleView.isHidden = true
            return
        }

        switch animated {
        case false:
            changeBackgroundColor(note: note)
        case true:
            UIView.animate(withDuration: Constants.animation.categorySwitchLength) {
                self.changeBackgroundColor(note: note)
            }
        }
    }
    
    private func changeBackgroundColor(note: Note) {
        if note.isPinned {
            triangleView.isHidden = true
            
            if let hex = note.category?.hexColor {
                let newCol = UIColor.init(hexString: hex).darker(by: 10)
                backgroundColor = newCol
            }
        } else {
            if note.category!.isNumbered {
                triangleView.isHidden = false
            } else {
                triangleView.isHidden = true
            }
            backgroundColor = .primary
        }
    }
}

