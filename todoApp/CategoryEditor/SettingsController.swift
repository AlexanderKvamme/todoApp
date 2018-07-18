//
//  SettingsController.swift
//  todoApp
//
//  Created by Alexander K on 26/06/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


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
        textField.text = currentCategory.name ?? "New Name"
        textField.sizeToFit()
        textField.delegate = self
    }
    
    private func setupSwitch() {
        mySwitch.isOn = currentCategory.isNumbered
        mySwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
    }
    
    private func addSubviewsAndConstraints() {
        view.addSubview(headerLabel)
        
        // Header
        headerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.leftMargin)
            make.top.equalTo(view.snp.topMargin)
        }
        
        // Set up other field based on setting type
        switch currentSettingType {
        case .color:
            fatalError()
        case .name:
            setupTextField()
            view.addSubview(textField)
            textField.snp.makeConstraints { (make) in
                make.top.equalTo(headerLabel.snp.bottom)
                make.left.equalTo(view.snp.leftMargin)
                make.right.equalTo(view.snp.rightMargin)
                make.bottom.equalTo(view.snp.bottomMargin)
            }
            
        case .isNumbered:
            setupSwitch()
            view.addSubview(mySwitch)
            
            mySwitch.snp.makeConstraints { (make) in
                make.top.equalTo(headerLabel.snp.bottom)
                make.left.equalTo(view.snp.leftMargin)
                make.right.equalTo(view.snp.rightMargin)
                make.bottom.equalTo(view.snp.bottomMargin)
            }
        }
    }
}

extension SettingsController {
    @objc fileprivate func switchToggled(_ theSwitch: UISwitch) {
        currentCategory.isNumbered = theSwitch.isOn
        
        /*
         let unPinnedNotes = currentCategory.getUnpinnedNotes()
         
         // New system doesnt need this, as all notes now have a number which represents position
        if theSwitch.isOn {
            print("bam gonna add numbers to these: ", unPinnedNotes)
            for (i,note) in unPinnedNotes.enumerated() {
                print("adding number \(i+1) to \(note)")
                note.number = Int16(i+1)
            }
        } else {
            for note in unPinnedNotes {
                note.removeNumber()
            }
        }
         */
        DatabaseFacade.saveContext()
    }
}

extension SettingsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let newText = textField.text, newText != " " else { return false }
        
        switch currentSettingType {
        case .name:
            currentCategory.name = newText
            DatabaseFacade.saveContext()
            textField.resignFirstResponder()
            return true
        default:
            return false
        }
    }
}




