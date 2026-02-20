//  Created by Ivan Khvorostinin on 21.07.2025.

import Foundation

@propertyWrapper
public class AnyVar<Value> {
    private let getter: () -> Value
    private let setter: (Value) -> Void

    public init(getter: @escaping () -> Value, setter: @escaping (Value) -> Void) {
        self.getter = getter
        self.setter = setter
    }

    public init(_ getter: @escaping () -> Value) {
        self.getter = getter
        self.setter = { _ in }
    }

    public convenience init(_ src: BoxedVar<Value>) {
        self.init(getter: { src.value }, setter: { src.value = $0 })
    }

    public convenience init(_ src: LockedVar<Value>) {
        self.init(getter: { src.value }, setter: { src.value = $0 })
    }

    public convenience init(_ src: AnyVar<Value>) {
        self.init(getter: { src.value }, setter: { src.value = $0 })
    }

    public convenience init(const src: Value) {
        self.init(getter: { src }, setter: { _ in })
    }

    public var wrappedValue: Value {
        get { getter() }
        set { setter(newValue) }
    }
    
    public var value: Value {
        get { getter() }
        set { setter(newValue) }
    }
}

@propertyWrapper
public class BoxedVar<Value> {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(_ value: Value) {
        self.wrappedValue = value
    }
    
    public var value: Value {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }
}

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

@propertyWrapper
class UncheckedVar<Value>: @unchecked Sendable {
    var wrappedValue: Value

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    init(_ value: Value) {
        self.wrappedValue = value
    }
}
