//  Created by Ivan Khvorostinin on 21.07.2025.

import Foundation

public protocol StringVar {
    var value: String { get set }
}

private extension String {
    class EmptyVar: StringVar {
        var value: String {
            get { "" }
            set {}
        }
    }
    
    class StringBlock: StringVar {
        let get: () -> String
        let set: (String) -> Void
        
        init(get: @escaping () -> String, set: @escaping (String) -> Void) {
            self.get = get
            self.set = set
        }
        
        var value: String {
            get { get() }
            set { set(newValue) }
        }
    }
}

public extension String {
    static let emptyVar: StringVar = EmptyVar()
    static func makeVar(get: @escaping () -> String,
                        set: @escaping (String) -> Void = { _ in }) -> StringVar {
        StringBlock(get: get, set: set)
    }
}
