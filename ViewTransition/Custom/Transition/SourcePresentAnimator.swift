//
//  SourcePresentAnimator.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class SourcePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var collectionView: UICollectionView?
    private let indexPath: IndexPath
    private let transitionId: String
    
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
    
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard
            let collectionView = collectionView,
            let targetView = collectionView.cellForItem(at: indexPath),
            let fromVC = ctx.viewController(forKey: .from),
            let toVC = ctx.viewController(forKey: .to),
            let snapshot = targetView.snapshotView(afterScreenUpdates: true),
            let toView = toVC.view.view(withId: transitionId),
            let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)
            else {
                ctx.completeTransition(!ctx.transitionWasCancelled)
                return
        }
        
        targetView.transitionId = transitionId
        
        let initialFrame = collectionView.convert(theAttributes.frame, to: collectionView.superview)
        let containerView = ctx.containerView
        containerView.backgroundColor = UIColor.white
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.addSubview(snapshot)
        snapshot.frame = initialFrame
        
        
        // layoutIfNeeded 를 호출하지 않으면 y 값이 어긋남
        toVC.view.layoutIfNeeded()
        
        toVC.view.alpha = 0
        toView.alpha = 0
        let finalFrame = toView.frame
        
        UIView.animate(withDuration: transitionDuration(using: ctx),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [UIView.AnimationOptions.transitionCrossDissolve],
                       animations: {
                        fromVC.view.alpha = 0
                        toVC.view.alpha = 1
                        snapshot.frame = finalFrame
        },
                       completion: { completed in
                        toVC.view.alpha = 1
                        toView.alpha = 1
                        snapshot.removeFromSuperview()
                        ctx.completeTransition(!ctx.transitionWasCancelled)
        })
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("animationEnded \(transitionCompleted)")
    }
}
