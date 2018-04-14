//
//  Constants.swift
//  todoApp
//
//  Created by Alexander K on 10/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

enum Constants {
    enum screen {
        static let height: CGFloat = {
            return UIScreen.main.bounds.height
        }()
        
        static let width: CGFloat = {
            return UIScreen.main.bounds.width
        }()
    }
    
    enum cells {
        static let defaultHeight: CGFloat = 100
    }
    
    enum keys {
        static let didSeedKey = "didSeedCoreDataWithMockNotes"
    }
}

