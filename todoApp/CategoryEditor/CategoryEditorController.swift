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


enum SettingType {
    case name
    case color
    case isNumbered
}


/// Lets user manage name, colors and other settings related to a category such as wether or not its numbered.
final class CategoryEditorController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let okButton = UIButton(frame: CGRect.zero)
    fileprivate let nameController: SettingsController
    fileprivate let isNumberedController: SettingsController
    
    private let currentCategory: Category
    
    weak var delegate: NoteTableController?
    
    // MARK: - Initializers
    
    init(for category: Category) {
        self.currentCategory = category
        self.nameController = SettingsController(withHeader: "NAME",
                                                 category: category,
                                                 settingType: .name)
        self.isNumberedController = SettingsController(withHeader: "NUMBERED",
                                                       category: category,
                                                       settingType: .isNumbered)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        setupButton()
        
        addGradientBackground()
        addSubviewsAndConstraints()
    }
    
    // MARK: - Methods
    
    private func setupButton() {
        okButton.backgroundColor = UIColor.primary
        okButton.setTitle("APPLY", for: .normal)
        okButton.titleLabel?.font = UIFont.custom(style: .bold, ofSize: .big)
        okButton.addTarget(self, action: #selector(applyAndDismiss), for: .touchUpInside)
    }
    
    private func addGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func addSubviewsAndConstraints() {
        view.addSubview(okButton)
        
        view.addSubview(nameController.view)
        view.addSubview(isNumberedController.view)
        
        addChildViewController(nameController)
        addChildViewController(isNumberedController)
        
        nameController.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
            make.height.equalTo(100)
        }
        
        isNumberedController.view.snp.makeConstraints { (make) in
            make.top.equalTo(nameController.view.snp.bottom)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
            make.height.equalTo(100)
        }
        
        okButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(100)
        }
    }
    
    // MARK: Selectors
    
    @objc private func applyAndDismiss() {
        delegate?.tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}











