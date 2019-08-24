//
//  CustomViewController.swift
//  ViewTransition
//
//  Created by tskim on 20/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class CustomViewController: UICollectionViewController {

    var fadeTransition: TransitioningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom"
    }
}

extension CustomViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageLoader.sampleImageURLs.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath)
    {
        (cell as! ThumbnailCell).imageView.kf.cancelDownloadTask()
    }
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell",
            for: indexPath) as! ThumbnailCell
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.isOpaque = true
        cell.imageView.kf.setImage(
            with: ImageLoader.sampleImageURLs[indexPath.row],
            placeholder: nil,
            options: [.transition(.fade(1)), .loadDiskFileSynchronously],
            progressBlock: { receivedSize, totalSize in
                print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
            }
        )
        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let vc = CustomImageViewController.initFromStoryboard(name: "Main")
        vc.modalPresentationStyle = .custom
        let dismissAnimator = SourceDismissAnimator(with: collectionView, for: indexPath, id: "image_\(indexPath.item)")
        let pre = UIInteractablePresentationController(presentedViewController: vc, presenting: self)
        fadeTransition = TransitioningDelegate(
            presentTransition: SourcePresentAnimator(with: collectionView, for: indexPath, id: "image_\(indexPath.item)"),
            dismissTransition: dismissAnimator,
            dismissInteraction: SwipeInteractivePercentDrivenTransition(gesture: pre.panGestureRecognizer, presented: vc),
//            dismissInteraction: SwipeInteractiveTransition(gesture: pre.panGestureRecognizer, animator: dismissAnimator, presented: vc),
            presentationController: pre
        )
        vc.transitioningDelegate = fadeTransition
        vc.modalPresentationStyle = .custom
        self.navigationController?.delegate = fadeTransition
        vc.indexPath = indexPath

        self.present(vc, animated: true)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

import UIKit

class UIInteractablePresentationController: UIPresentationController {

    let panGestureRecognizer = UIPanGestureRecognizer()

    override func presentationTransitionWillBegin() {
        print("call presentationTransitionWillBegin")
        super.presentationTransitionWillBegin()
        guard let presentedView = presentedView else { return }
        presentedView.addGestureRecognizer(panGestureRecognizer)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        print("call presentationTransitionDidEnd: \(completed)")
        super.presentationTransitionDidEnd(completed)
    }
    
    @objc
    func dismissalGesture(gesture: UIPanGestureRecognizer) {
        
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        print("call dismissalTransitionDidEnd: \(completed)")
    }
    override func dismissalTransitionWillBegin() {
        print("call dismissalTransitionWillBegin")
    }
}


import UIKit

internal class SwipeInteractivePercentDrivenTransition: UIPercentDrivenInteractiveTransition {

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

import UIKit

internal class SwipeInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {

    private var animator: UIViewControllerAnimatedTransitioning
    private var gesture: UIGestureRecognizer
    var presented: UIViewController?

    private weak var transitionContext: UIViewControllerContextTransitioning?

    // MARK: - Initialization

    init(
        gesture: UIGestureRecognizer,
        animator: UIViewControllerAnimatedTransitioning,
        presented: UIViewController
    ) {
//        guard SwipeInteractiveTransition.isSupported(animator: animator) else {
//            fatalError("Warning! Animator must implement interruptibleAnimator method to be used with SwipeInteractiveTransition!")
//        }
        self.gesture = gesture
        self.animator = animator
        self.presented = presented
        super.init()
        gesture.addTarget(self, action: #selector(onGestureRecognized))
    }

    // MARK: - UIPercentDrivenInteractiveTransition

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        print("startInteractiveTransition:transitionContext \(transitionContext)")
        self.transitionContext = transitionContext
        animator.animateTransition(using: transitionContext)
        let interruptibleAnimator = animator.interruptibleAnimator?(using: transitionContext)
        interruptibleAnimator?.addCompletion?() { (pos) in
            self.animator.animationEnded?(!transitionContext.transitionWasCancelled)
        }
        interruptibleAnimator?.pauseAnimation()
    }

    // MARK: - Private

    @objc private func onGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("!!!!!!!!!!!! began")
            self.presented?.dismissViewController()
        case .changed:
            guard let view = gesture.view else { return }
            let delta = gesture.translation(in: view)
            let percent = abs(delta.y / view.bounds.size.width)
            self.update(percent)
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
            cancel()
        case .failed:
            cancel()
        default:
            break
        }
    }

    private func getReletiveTranslationInTargetView(forGesture gesture: UIPanGestureRecognizer) -> CGFloat {
        guard let view = transitionContext?.view(forKey: .to) else {
            return 0.0
        }
        return gesture.translation(in: view).x / view.bounds.width
    }

    private class func isSupported(animator: UIViewControllerAnimatedTransitioning) -> Bool {
        let selector = #selector(UIViewControllerAnimatedTransitioning.interruptibleAnimator)
        return animator.responds(to: selector)
    }

    private func update(_ percentComplete: CGFloat) {
        print("update \(percentComplete)")
        guard let context = transitionContext else {
            fatalError("SwipeInteractiveTransition:startInteractiveTransition must be called before this method!")
        }
        let clampedFraction = percentComplete.clamped(to: 0.0 ... 1.0)
        animator.interruptibleAnimator?(using: context).fractionComplete = clampedFraction
        context.updateInteractiveTransition(clampedFraction)
    }

    private func finish() {
        print("finish")
        guard let context = transitionContext else {
            fatalError("SwipeInteractiveTransition:startInteractiveTransition must be called before this method!")
        }
        animator.interruptibleAnimator?(using: context).startAnimation()
        context.finishInteractiveTransition()
    }

    private func cancel() {
        print("cancel")
        guard let context = transitionContext else {
            fatalError("SwipeInteractiveTransition:startInteractiveTransition must be called before this method!")
        }
        let interruptibleAnimator = animator.interruptibleAnimator?(using: context)
        interruptibleAnimator?.isReversed = true
        interruptibleAnimator?.startAnimation()
        context.cancelInteractiveTransition()
    }
}

class SourceDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let collectionView: UICollectionView
    private let indexPath: IndexPath
    private let transitionId: String

    private var animator: UIViewImplicitlyAnimating?
    
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
        toVC.view.layer.mask = nil
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
            
        }
        return animator
    }
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        if let localAnimator = animator {
            self.animator = localAnimator
        } else {
            self.animator = interruptibleAnimator(using: ctx)
        }
        if self.animator?.state == .inactive {
            self.animator?.pauseAnimation()
        }
    }
}


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
        containerView.addSubview(toVC.view)
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
                fromVC.view.alpha = 1
                toView.alpha = 1
                snapshot.removeFromSuperview()
                ctx.completeTransition(!ctx.transitionWasCancelled)
            })
    }
}
