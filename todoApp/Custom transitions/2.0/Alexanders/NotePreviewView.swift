//
//  NotePreviewView.swift
//  todoApp
//
//  Created by Alexander K on 31/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


final class NotePreviewView: UIView {

    // MARK: - Properties
    
    private let textView = UITextView() // to let user edit notes
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
        addSubviewsAndConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setup() {
        backgroundColor = UIColor.primary
        
        textView.textColor = UIColor.primaryContrast
        textView.font = UIFont.custom(style: CustomFont.bold, ofSize: .big)
        textView.backgroundColor = .clear
    
        textView.delegate = self
    }
    
    func update(with note: Note) {
        textView.text = note.content ?? "NO CONTENT"
    }
    
    private func addSubviewsAndConstraints() {
        addSubview(textView)
        let spacing: CGFloat = 10
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(snp.top).offset(spacing)
            make.left.equalTo(snp.left).offset(spacing)
            make.right.equalTo(snp.right).offset(-spacing)
            make.bottom.equalTo(snp.bottom).offset(-spacing)
        }
    }
    
    private func animateDismissal() {
        print("would animate dismissal")
    }
}

// MARK: - UITextViewDelegate Conformance

extension NotePreviewView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            animateDismissal()
            return false
        }
        
        return true
    }
}
