//
//  DetailedNoteViewController.swift
//  todoApp
//
//  Created by Alexander K on 24/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class DetailViewController: UIViewController {
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .lightGray
        
        let edge = UIScreenEdgePanGestureRecognizer(target: self,
                                                    action: #selector(self.handleEdgePan(_:)))
        edge.edges = .left
        self.view.addGestureRecognizer(edge)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.delegate = self
    }
    
    @objc func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent = translate.x / gesture.view!.bounds.size.width
        
        switch gesture.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            self.navigationController?.popViewController(animated: true)
        case .changed:
            self.interactionController?.update(percent)
        case .ended:
            let velocity = gesture.velocity(in: gesture.view)
            
            if percent > 0.5 || velocity.x > 0 {
                self.interactionController?.finish()
            }
            else {
                self.interactionController?.cancel()
            }
            self.interactionController = nil
        default:
            break
        }
    }
    
    
    /* ... */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let controller = segue.destination as? ModalViewController else {
            return
        }
        
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
    }
}


open class FadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePushAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadePopAnimator(type: .modal)
    }
}

extension DetailViewController: UINavigationControllerDelegate {
    
    /* ... */
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return self.interactionController
    }
}


open class FadePopAnimator: CustomAnimator {
    
    open override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    open override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        
        transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
