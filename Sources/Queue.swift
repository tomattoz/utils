//  Created by Ivan Kh on 10.10.2025.

import Foundation

public actor TaskQueue {
    private let capacity: UInt
    private var activeCount: UInt = 0
    private var continuations = [CheckedContinuation<Void, Never>]()
    private let id = String.randomLetters(length: 3)

    public init(capacity: UInt = 1) {
        self.capacity = capacity
    }
    
    public func exec<Result>(_ block: () async throws -> Result) async throws -> Result {
        if activeCount < capacity {
            activeCount += 1
            return try await _exec(block)
        }
        else {
            await withCheckedContinuation { continuation in
                _exec(continuation: continuation)
            }
            
            return try await _exec(block)
        }
    }
    
    private func _exec(continuation: CheckedContinuation<Void, Never>) {
        if activeCount < capacity {
            activeCount += 1
            continuation.resume()
        }
        else {
            continuations.append(continuation)
        }
    }
    
    private func _exec<Result>(_ block: () async throws -> Result) async throws -> Result {
        defer {
            if let first = continuations.first {
                continuations.removeFirst()
                first.resume()
            }
            else {
                self.activeCount -= 1
            }
        }
        
        do {
            let result = try await block()
            return result
        }
        catch {
            throw error
        }
    }
}

public actor IntervalTaskQueue {
    private let interval: TimeInterval
    private var lastExecDate = Date()
    private let queue = TaskQueue()
    
    public init(interval: TimeInterval = 1) {
        self.interval = interval
    }
    
    public func exec<Result>(_ block: () async throws -> Result) async throws -> Result {
        try await queue.exec {
            let interval = Date().timeIntervalSince(self.lastExecDate)
            
            if interval < self.interval {
                let nanos = UInt64((self.interval - interval) * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanos)
            }
            
            log("INTERVAL \(Date().timeIntervalSince(self.lastExecDate))")
            let result = try await block()
            self.lastExecDate = Date()
            return result
        }
    }
}

public actor AccessQueue<T> {
    private var objects: [T]
    private var continuations = [CheckedContinuation<T, Never>]()

    public init(_ objects: [T]) {
        self.objects = objects
    }
    
    public func exec<Result>(_ block: (T) async throws -> Result) async throws -> Result {
        let object: T
        
        if !objects.isEmpty {
            object = objects.removeLast()
        }
        else {
            object = await withCheckedContinuation { continuation in
                if !objects.isEmpty {
                    continuation.resume(returning: objects.removeFirst())
                }
                else {
                    continuations.append(continuation)
                }
            }
        }
        
        defer {
            if let next = continuations.first {
                continuations.removeFirst()
                next.resume(returning: object)
            }
            else {
                objects.append(object)
            }
        }
        
        return try await block(object)
    }
}
