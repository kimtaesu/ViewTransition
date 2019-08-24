//
//  InteractivePercentDrivenTransition.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

internal class InteractivePercentDrivenTransition: UIPercentDrivenInteractiveTransition {
    
    private var gesture: UIGestureRecognizer
    unowned let presented: UIViewController
    
    // MARK: - Initialization
    
    public init?(gesture: UIGestureRecognizer, presented: UIViewController) {
        self.gesture = gesture
        self.presented = presented
        super.init()
        gesture.addTarget(self, action: #selector(onGestureRecognized))
    }
    
    private class func isSupported(animator: UIViewControllerAnimatedTransitioning) -> Bool {
        let selector = #selector(UIViewControllerAnimatedTransitioning.interruptibleAnimator)
        return animator.responds(to: selector)
    }
    
    // MARK: - UIPercentDrivenInteractiveTransition
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        print("startInteractiveTransition \(transitionContext)")
        super.startInteractiveTransition(transitionContext)
        pause()
    }
    @objc private func onGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.presented.dismissViewController()
        case .changed:
            guard let view = gesture.view else { return }
            let delta = gesture.translation(in: view)
            let percent = abs(delta.y / view.bounds.size.width)
            update(percent)
        case .ended:
            guard let view = gesture.view else { return }
            let delta = gesture.translation(in: view)
            let percent = abs(delta.y / view.bounds.size.width)
            
            if percent.isLess(than: 0.3) {
                cancel()
            } else {
                finish()
            }
        case .cancelled:
            break
        default:
            break
        }
    }
}
