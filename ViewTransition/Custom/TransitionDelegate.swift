//
//  TransitionDelegate.swift
//  ViewTransition
//
//  Created by tskim on 22/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//
import UIKit

open class TransitioningDelegate: NSObject {
    
    // MARK: Properties
    
    open var presentTransition: UIViewControllerAnimatedTransitioning?
    open var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    open var presentInteraction: UIViewControllerInteractiveTransitioning?
    open var dismissInteraction: UIViewControllerInteractiveTransitioning?
    
    open var presentationController: UIPresentationController?
    
    // MARK: Init
    
    public init(presentTransition: UIViewControllerAnimatedTransitioning? = nil,
                dismissTransition: UIViewControllerAnimatedTransitioning? = nil,
                presentInteraction: UIViewControllerInteractiveTransitioning? = nil,
                dismissInteraction: UIViewControllerInteractiveTransitioning? = nil,
                presentationController: UIPresentationController? = nil) {
        self.presentTransition = presentTransition
        self.dismissTransition = dismissTransition
        self.presentInteraction = presentInteraction
        self.dismissInteraction = dismissInteraction
        self.presentationController = presentationController
    }
    
}

extension TransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    open func animationController(forPresented presented: UIViewController,
                                  presenting: UIViewController,
                                  source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
    
    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentInteraction
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteraction
    }
    
    open func presentationController(forPresented presented: UIViewController,
                                     presenting: UIViewController?,
                                     source: UIViewController) -> UIPresentationController? {
        return presentationController
    }
    
}

extension TransitioningDelegate: UINavigationControllerDelegate {
    
    open func navigationController(_ navigationController: UINavigationController,
                                   animationControllerFor operation: UINavigationController.Operation,
                                   from fromVC: UIViewController,
                                   to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return presentTransition
        case .pop:
            return dismissTransition
        default:
            return nil
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController,
                                   interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentInteraction
    }
    
}

extension TransitioningDelegate: UITabBarControllerDelegate {
    
    open func tabBarController(_ tabBarController: UITabBarController,
                               animationControllerForTransitionFrom fromVC: UIViewController,
                               to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    open func tabBarController(_ tabBarController: UITabBarController,
                               interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentInteraction
    }
    
}
