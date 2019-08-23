//
//  CustomViewController.swift
//  ViewTransition
//
//  Created by tskim on 20/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class CustomViewController: UICollectionViewController {

    var slideTransition: TransitioningDelegate?

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
        let item = ImageLoader.sampleImageURLs[indexPath.item]
        print("item: \(item)")

        let vc = CustomImageViewController.initFromStoryboard(name: "Main")
        let targetView = collectionView.cellForItem(at: indexPath) ?? UIView()

        targetView.transitionId = "image_\(indexPath.item)"
        let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        let sourceViewFrame = collectionView.convert(theAttributes?.frame ?? .zero, to: collectionView.superview)
        slideTransition = TransitioningDelegate(
            presentTransition: SourceAnimator(target: targetView, origin: sourceViewFrame, transitionId: targetView.transitionId)
//            dismissTransition: SourceAnimator(originFrame: sourceViewFrame, key: indexPath.item),
//            dismissInteraction: SwipeInteractiveTransition(gesture: UIPanGestureRecognizer(), animator: SourceAnimator(originFrame: sourceViewFrame, key: indexPath.item))
        )
        vc.transitioningDelegate = slideTransition
        vc.indexPath = indexPath
        self.present(vc, animated: true)
    }
}


class SourceAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let transitionId: String?
    private let originFrame: CGRect
    private let targetView: UIView

    init(target: UIView, origin: CGRect, transitionId: String?) {
        self.transitionId = transitionId
        self.targetView = target
        self.originFrame = origin
    }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard let fromVC = ctx.viewController(forKey: .from),
            let toVC = ctx.viewController(forKey: .to),
            let toView = toVC.view.view(withId: self.transitionId),
            let snapshot = self.targetView.snapshotView(afterScreenUpdates: true)
            else {
                return
        }


        let initialFrame = self.originFrame

        let containerView = ctx.containerView
        containerView.backgroundColor = UIColor.white
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        snapshot.frame = initialFrame

        // layoutIfNeeded 를 호출하지 않으면 y 값이 어긋남
        toVC.view.layoutIfNeeded()

        toVC.view.alpha = 0
        let finalFrame = toView.frame

        UIView.animate(withDuration: transitionDuration(using: ctx),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [UIView.AnimationOptions.transitionCrossDissolve],
            animations: {
                fromVC.view.alpha = 0
                snapshot.frame = finalFrame
            },
            completion: { completed in
                snapshot.removeFromSuperview()
                toVC.view.alpha = 1
                fromVC.view.alpha = 1
                ctx.completeTransition(!ctx.transitionWasCancelled)
            })
//        UIView.animate(
//            withDuration: transitionDuration(using: ctx), animations: {
//                snapshot.frame = finalFrame
//            }) { _ in
//            snapshot.removeFromSuperview()
//            toVC.view.alpha = 1
//            ctx.completeTransition(!ctx.transitionWasCancelled)
//        }
    }


}
import UIKit

internal class SwipeInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {

    private var animator: UIViewControllerAnimatedTransitioning
    private var gesture: UIGestureRecognizer

    private weak var transitionContext: UIViewControllerContextTransitioning?

    // MARK: - Initialization

    public init?(gesture: UIGestureRecognizer, animator: UIViewControllerAnimatedTransitioning) {
        guard SwipeInteractiveTransition.isSupported(animator: animator) else {
            print("Warning! Animator must implement interruptibleAnimator method to be used with SwipeInteractiveTransition!")
            return nil
        }
        self.gesture = gesture
        self.animator = animator
        super.init()
        gesture.addTarget(self, action: #selector(onGestureRecognized))
    }

    // MARK: - UIPercentDrivenInteractiveTransition

    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        animator.animateTransition(using: transitionContext)
        let interruptibleAnimator = animator.interruptibleAnimator?(using: transitionContext)
        interruptibleAnimator?.addCompletion?() { (pos) in
            self.animator.animationEnded?(!transitionContext.transitionWasCancelled)
        }
        interruptibleAnimator?.pauseAnimation()
    }

    // MARK: - Private

    @objc private func onGestureRecognized(_ sender: UIPanGestureRecognizer) {
        print("onGestureRecognized")
        switch sender.state {
        case .changed:
            let reletiveTranslation = getReletiveTranslationInTargetView(forGesture: sender)
            self.update(reletiveTranslation)
        case .ended:
            let performer = sender.velocity(in: sender.view).x > 0 ? finish : cancel
            performer()
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
        guard let context = transitionContext else {
            fatalError("SwipeInteractiveTransition:startInteractiveTransition must be called before this method!")
        }
        let clampedFraction = percentComplete.clamped(to: 0.0 ... 1.0)
        animator.interruptibleAnimator?(using: context).fractionComplete = clampedFraction
        context.updateInteractiveTransition(clampedFraction)
    }

    private func finish() {
        guard let context = transitionContext else {
            fatalError("SwipeInteractiveTransition:startInteractiveTransition must be called before this method!")
        }
        animator.interruptibleAnimator?(using: context).startAnimation()
        context.finishInteractiveTransition()
    }

    private func cancel() {
        guard let context = transitionContext else {
            fatalError("SwipeInteractiveTransition:startInteractiveTransition must be called before this method!")
        }
        let interruptibleAnimator = animator.interruptibleAnimator?(using: context)
        interruptibleAnimator?.isReversed = true
        interruptibleAnimator?.startAnimation()
        context.cancelInteractiveTransition()
    }
}


extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}
//
//import UIKit
//
//protocol UIAnimatedInteractionController: UIViewControllerInteractiveTransitioning {
//
//    var animationController: UIViewControllerAnimatedTransitioning? { get set }
//
//    func canDoInteractiveTransition() -> Bool
//    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning)
//    func gestureRecognizerStateChanged(withTranslation translation: CGPoint)
//    func gestureRecognizerEnded()
//
//}
//
import UIKit

//class UIInteractablePresentationController: UIPresentationController {
//
//    var interactiveDismissalEnabled: Bool {
//        return true
//    }
//
//    private(set) var isInteracting = false
//    weak var animatedInteractionController: UIAnimatedInteractionController?
//
//    required override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
//        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
//    }
//
//    @objc func aa(gestureRecognizer: UIPanGestureRecognizer) {
//        // Cancel touches while animating.
//        if let animatedInteractionController = animatedInteractionController {
//            if !animatedInteractionController.canDoInteractiveTransition() {
//                gestureRecognizer.isEnabled = false
//                gestureRecognizer.isEnabled = true
//                return
//            }
//        }
//
//        switch gestureRecognizer.state {
//
//        case .began:
//            isInteracting = true
//            presentingViewController.dismiss(animated: true, completion: nil)
//
//        case .changed:
//            guard
//                let view = gestureRecognizer.view,
//                let animatedInteractionController = animatedInteractionController
//                else { break }
//
//            let translation = gestureRecognizer.translation(in: view)
//            animatedInteractionController.gestureRecognizerStateChanged(withTranslation: translation)
//
//        case .ended, .cancelled:
//            isInteracting = false
//
//            guard let animatedInteractionController = animatedInteractionController else { break }
//            animatedInteractionController.gestureRecognizerEnded()
//
//        default: break
//        }
//    }
//    override func presentationTransitionDidEnd(_ completed: Bool) {
//        super.presentationTransitionDidEnd(completed)
//
//        guard interactiveDismissalEnabled,
//            completed,
//            let presentedView = presentedView
//            else { return }
//
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(aa))
//
//        presentedView.addGestureRecognizer(panGestureRecognizer)
//    }
//
//}
private var transitionContext: UInt8 = 0

extension UIView {

    func synchronized<T>(_ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }

    public var transitionId: String? {
        get {
            return synchronized {
                if let transitionId = objc_getAssociatedObject(self, &transitionContext) as? String {
                    return transitionId
                }
                return nil
            }
        }

        set {
            synchronized {
                objc_setAssociatedObject(self, &transitionContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    func view(withId id: String?) -> UIView? {
        if id?.isEmpty == true { return nil }
        return self.subviews.first { $0.transitionId == id }
    }
}
//enum ViewIdentifier {
//    case transitionId(String)
//}
//extension UIView {
//    var identifier: ViewIdentifier? {
//        set {
//            guard let value = newValue else { return }
//            switch value {
//            case .transitionId(let id):
//                break
//            default:
//                break
//            }
//        }
//        get {
//            return ViewIdentifier(rawValue: self.tag)
//        }
//    }
//    func view(withId id: ViewIdentifier) -> UIView? {
//        return self.viewWithTag(id.rawValue)
//    }
//}
