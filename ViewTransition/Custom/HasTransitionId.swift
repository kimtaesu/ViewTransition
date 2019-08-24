//
//  HasTransitionId.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

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
