//
//  NoteDelegate.swift
//  todoApp
//
//  Created by Alexander K on 16/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class NoteDelegate: NSObject, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteCellView.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        print("did end editing")
    }
    
}
