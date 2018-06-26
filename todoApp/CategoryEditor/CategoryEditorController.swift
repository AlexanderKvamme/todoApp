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
}


/// Lets user manage name, colors and other settings related to a category such as wether or not its numbered.
final class CategoryEditorController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let okButton = UIButton(frame: CGRect.zero)
    fileprivate let nameController: SettingsController
    
    private let currentCategory: Category
    
    weak var delegate: NoteTableController?
    
    // MARK: - Initializers
    
    init(for category: Category) {
        self.currentCategory = category
        self.nameController = SettingsController(withHeader: "NAME", category: category, settingType: SettingType.name)
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
        
        addChildViewController(nameController)
        
        nameController.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin)
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











protocol CategorySetting {}

final class SettingsController: UIViewController {
    
    // MARK: - Properties
    
    private let currentSettingType: SettingType
    private let currentCategory: Category
    
    private let headerLabel = UILabel()
    private let mySwitch = UISwitch()
    private let textField = UITextField()
//    private let colorPicker = https://github.com/joncardasis/ChromaColorPicker
    
    // MARK: - Initializers
    
    init(withHeader headline: String, category: Category, settingType: SettingType) {
        self.currentSettingType = settingType
        self.currentCategory = category
        headerLabel.text = headline
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupHeader()
        addSubviewsAndConstraints()
    }
    
    // MARK: - Methods
    
    private func setupHeader() {
        headerLabel.textColor = .white
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .biggest)
    }
    
    private func setupTextField() {
        textField.textColor = .white
        textField.font = UIFont.custom(style: .bold, ofSize: .medium)
        textField.backgroundColor = .red
        textField.delegate = self
    }

    private func addSubviewsAndConstraints() {
        view.addSubview(headerLabel)
        
        // Header
        headerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.leftMargin)
            make.top.equalTo(view.snp.topMargin)
        }
        
        switch currentSettingType {
        case .color:
            fatalError()
        case .name:
            setupTextField()
            view.addSubview(textField)
            textField.snp.makeConstraints { (make) in
                make.top.equalTo(headerLabel.snp.bottom).offset(10)
                make.left.equalTo(view.snp.leftMargin)
                make.right.equalTo(view.snp.rightMargin)
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        }
    }
}

extension SettingsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.warning("textFieldShouldReturn")
        guard let newText = textField.text, newText != " " else { return false }
        
        switch currentSettingType {
        case .name:
            log.warning("would update name")
            currentCategory.name = newText
            textField.resignFirstResponder()
            return true
        default:
            return false
        }
    }
}




