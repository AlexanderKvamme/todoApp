//
//  CategoryEditorController.swift
//  todoApp
//
//  Created by Alexander K on 25/06/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


/// Lets user manage name, colors and other settings related to a category such as wether or not its numbered.
final class CategoryEditorController: UIViewController {
    
    // MARK: - Properties
    
    private let currentCategory: Category
    
    // MARK: - Initializers
    
    init(for category: Category) {
        self.currentCategory = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        print("view did load bro")
        addSubviewsAndConstraints()
    }
    
    // MARK: - Methods
    
    private func addSubviewsAndConstraints() {
        let v = UIView(frame: CGRect.zero)
        let gradient = CAGradientLayer()
        
        gradient.frame = view.bounds
        gradient.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        view.addSubview(v)
    }
}

