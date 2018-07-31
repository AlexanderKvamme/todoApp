//
//  ModalViewController.swift
//  todoApp
//
//  Created by Alexander K on 24/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
//
//  ModalViewController.swift
//  CustomTransition
//
//  Created by Tibor Bödecs on 2018. 04. 25..
//  Copyright © 2018. Tibor Bödecs. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    var interactionController: LeftEdgeInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .orange
        
        self.interactionController = LeftEdgeInteractionController(viewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ModalViewController")
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

