//
//  NoteTableViewDelegate.swift
//  todoApp
//
//  Created by Alexander K on 16/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class NoteTableViewDelegate: NSObject, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NoteCellView.defaultHeight
    }
}

