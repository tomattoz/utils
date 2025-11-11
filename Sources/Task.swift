//  Created by Ivan Kh on 22.10.2025.

import Foundation

public func withThrowingTimeout9<T>(
    seconds: Double,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw Error9.Timeout()
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
