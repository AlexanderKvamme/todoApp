//
//  BigCaretTextField.swift
//  todoApp
//
//  Created by Alexander K on 17/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Textfield with a thicker Caret
class BigCaretTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        let height = self.frame.height
        let superpos = super.caretRect(for: position)
        let rect = CGRect(x: superpos.maxX, y: superpos.minY, width: 5, height: height)
        return rect
    }
}
