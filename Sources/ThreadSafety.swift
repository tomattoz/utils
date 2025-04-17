//  Created by Ivan Khvorostinin on 23.01.2025.

import Foundation

public final class LockedVar<Value>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSLock()

    public init(_ value: Value) {
        self._value = value
    }

    public var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
}

//@propertyWrapper struct LockedVar<Value>: @unchecked Sendable {
//    let lock: NSLock
//    var value: Value
//
//    init(wrappedValue: Value, lock: NSLock = NSLock()) {
//        self.value = wrappedValue
//        self.lock = lock
//    }
//
//    var wrappedValue: Value {
//        get {
//            lock.locked { value }
//        }
//        set {
//            lock.locked { value = newValue }
//        }
//    }
//}

extension NSLock {
    // use it for compatibility with Linux
    public func locked<R>(_ body: () throws -> R) rethrows -> R {
        lock()
        
        defer {
            unlock()
        }
        
        return try body()
    }
}
