//  Created by Ivan Khvorostinin on 23.01.2025.

import Foundation

@propertyWrapper
public final class LockedVar<Value>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSLock()

    public init(wrappedValue: Value) {
        self._value = wrappedValue
    }

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
    
    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }
    
    public var projectedValue: LockedVar<Value> {
        return self
    }
}

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
