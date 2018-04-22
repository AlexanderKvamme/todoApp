
//
//  NoteCell.swift
//  todoApp
//
//  Created by Alexander K on 27/03/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit


final class NoteCell: SwipeTableViewCell {
    
    // MARK: Properties
    
    static let identifier = "NOTECELL"
    
    let noteCellView = NoteCellView()
    
    // MARK: Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviewsAndConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func addSubviewsAndConstraints() {
        contentView.addSubview(noteCellView)
        
        noteCellView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
            make.height.equalTo(NoteCellView.defaultHeight).priority(999) // this proprity removes apple bug error print
        }
    }
    
    // MARK: internal methods
    
    func updateWith(note: Note, at index: Int) {
        noteCellView.updateWith(note: note, at: index)
    }
}

