//  Created by Ivan Kh on 16.12.2024.

import Foundation

public struct Hashable2Identifiable<T>: Identifiable where T: Hashable {
    public let inner: T
    
    public var id: Int {
        inner.hashValue
    }
}
