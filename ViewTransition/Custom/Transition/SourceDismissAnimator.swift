//
//  SourceDismissAnimator.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class SourceDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let collectionView: UICollectionView
    private let indexPath: IndexPath
    private let transitionId: String
    
    private var animator: UIViewImplicitlyAnimating?
    
    private var isAnimating: Bool = false
    
    init(
        with collectionView: UICollectionView,
        for indexPath: IndexPath,
        id transitionId: String
        ) {
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.transitionId = transitionId
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    func interruptibleAnimator(using ctx: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if self.animator != nil {
            return self.animator!
        }
        let rootVC = ctx.viewController(forKey: .from)
        let _fromVC = rootVC?.navigationController?.topViewController ?? rootVC
        guard let fromVC = _fromVC,
            let targetView = fromVC.view.view(withId: transitionId),
            let toVC = ctx.viewController(forKey: .to),
            let snapshot = targetView.snapshotView(afterScreenUpdates: true),
            let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)
            else {
                ctx.completeTransition(!ctx.transitionWasCancelled)
                return UIViewPropertyAnimator()
        }
        let initialFrame = targetView.frame
        let finalFrame = collectionView.convert(theAttributes.frame, to: collectionView.superview)
        
        let containerView = ctx.containerView
        containerView.backgroundColor = UIColor.white
        containerView.insertSubview(toVC.view, belowSubview: toVC.view)
        containerView.addSubview(snapshot)
        snapshot.frame = initialFrame
        
        toVC.view.alpha = 0
        fromVC.view.alpha = 1
        targetView.alpha = 0
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: ctx),
            curve: .easeOut) {
                toVC.view.alpha = 1
                fromVC.view.alpha = 0
                snapshot.frame = finalFrame
        }
        
        animator.addCompletion { position in
            switch position {
            case .start:
                fromVC.view.alpha = 1
                toVC.view.alpha = 0
                targetView.alpha = 1
            case .end:
                toVC.view.alpha = 1
                fromVC.view.alpha = 0
                targetView.alpha = 0
            case .current: break
            @unknown default: break
            }
            snapshot.removeFromSuperview()
            ctx.completeTransition(!ctx.transitionWasCancelled)
            self.isAnimating = false
            // black screen after transition
            // https://stackoverflow.com/questions/24338700/from-view-controller-disappears-using-uiviewcontrollercontexttransitioning/25655575#25655575
            UIApplication.shared.keyWindow?.addSubview(toVC.view)
            
        }
        self.animator = animator
        return animator
    }
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: ctx)
        if animator.state == .inactive {
            animator.startAnimation()
        }
    }
    func animationEnded(_ transitionCompleted: Bool) {
        print("animationEnded \(transitionCompleted)")
    }
}
