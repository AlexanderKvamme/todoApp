//
//  MyNavigationController.swift
//  todoApp
//
//  Created by Alexander K on 01/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class MyNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        self.transitioningDelegate = self
        self.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewDidLoad() {
//        
//        var vcs = [NoteTableController]()
//        let noteStorage = CoreDataStorage()
//        
//        for (i, cat) in Categories.all.enumerated() {
//            let vc = NoteTableController(with: noteStorage, andCategory: cat)
//            vcs.append(vc)
//            //            if i > 0 {
//            //                print("setting next")
//            //                vcs[i-1].nextNoteTable = vc }
//        }
//        
//        setViewControllers(vcs, animated: false)
//    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController,source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // FIXME: Use black center frams
        print("bama getting custom AnimationController ")
        return FlipPresentAnimationController(originFrame: view.frame)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("*bama preparing for segue in nav*")
    }
    
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        print("*bama preparing to push in nav*")
//
//        super.pushViewController(viewController, animated: animated)
//    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        print("*bama show in nav*")
    }
}

extension MyNavigationController: UIViewControllerTransitioningDelegate {
    
}

extension MyNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("*bama custom push*")
        
        switch operation {
        case .push:
            return SlideAnimator()
//            return FlipPresentAnimationController(originFrame: self.view.frame)
        default:
            return nil
        }
    }
}
