//
//  Design.swift
//  todoApp
//
//  Created by Alexander K on 01/10/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


struct Design {
    enum cell {
        enum alpha {
            enum number {
                static let pinned: CGFloat = 0
                static let unpinned: CGFloat = 0.2
            }
            
            enum moveCellIcon {
                static let pinned: CGFloat = 0
                static let unpinned: CGFloat = 1
            }
            
            enum separator {
                static let top: CGFloat = 0.02
                static let bottom: CGFloat = 0.1
            }
        }
        
        enum size {
                static let moveIcon: CGFloat = 20
        }
        
        enum color {
            enum separator {
                static let top: UIColor = .white
                static let bottom: UIColor = .black
            }
        }
    }
}

