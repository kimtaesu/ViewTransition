//
//  UIViewController+Transition.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

extension UIViewController {
    public func dismissViewController(completion: (() -> Void)? = nil) {
        if let navigationController = self.navigationController, navigationController.viewControllers.first != self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: completion)
        }
    }

}
