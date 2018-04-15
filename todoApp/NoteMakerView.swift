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
import SnapKit


/// Small view that is basically a pretty textfield to be shown over a new cell before it has content
class NoteMakerView: DGElasticPullToRefreshLoadingView {
    
    // MARK: - Properties
    
    static var height: CGFloat = {
       return NoteCellView.defaultHeight
    }()
    
    static var width: CGFloat = {
        return Constants.screen.width
    }()
    
    var textField: UITextField = {
        let field = UITextField()
        field.textAlignment = .center
        field.clearsOnBeginEditing = true
        field.textColor = .primaryContrast
        field.font = .custom(style: .bold, ofSize: .bigger)
        return field
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondary
        
        addTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func addTextField() {
        addSubview(textField)
        
        textField.snp.makeConstraints { (make) in
            make.center.equalTo(snp.center)
        }
    }
}

