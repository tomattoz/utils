//  Created by Ivan Khvorostinin on 21.07.2025.

import Foundation

@propertyWrapper
public class BoxedVar<Value> {
    public var wrappedValue: Value
    
    public init(_ value: Value) {
        self.wrappedValue = value
    }
}
