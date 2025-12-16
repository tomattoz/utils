//  Created by Ivan Khvorostinin on 23.01.2025.

import Foundation

extension NSLock {
    // use it for compatibility with Linux where withLock is unavailable
    public func locked<R>(_ body: () throws -> R) rethrows -> R {
        lock()
                
        defer {
            unlock()
        }
        
        return try body()
    }
}
