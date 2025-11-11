//  Created by Ivan Kh on 24.09.2025.

import Foundation

public extension BinaryFloatingPoint {
    func percentDifference(_ other: Self) -> Self {
        let a = self
        let b = other
        let avg = (Swift.abs(a) + Swift.abs(b)) / 2
        if avg == 0 { return 0 }
        return Swift.abs(a - b) / avg * 100
    }
    
    func isAlmostEqual(to other: Self, tolerance: Self = .ulpOfOne) -> Bool {
        return Swift.abs(self - other) <= tolerance
    }
}

public extension BinaryInteger {
    func percentDifference(_ other: Self) -> Double {
        let a = Double(self)
        let b = Double(other)
        let avg = (Swift.abs(a) + Swift.abs(b)) / 2
        if avg == 0 { return 0 }
        return Swift.abs(a - b) / avg * 100
    }
}
