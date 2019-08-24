//
//  FloatingPoint+.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}
