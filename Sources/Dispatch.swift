//  Created by Ivan Kh on 14.01.2026.

import Foundation

public func dispatchMainSync<T>(execute block: () -> T) -> T {
    if Thread.isMainThread {
        block()
    }
    else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

public func dispatchMainSync<T>(execute block: () throws -> T) throws -> T {
    if Thread.isMainThread {
        try block()
    }
    else {
        try DispatchQueue.main.sync {
            try block()
        }
    }
}
