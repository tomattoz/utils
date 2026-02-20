//  Created by Ivan Kh on 10.10.2025.

import Foundation

public protocol AsyncThrowingQueue {
    func exec<Result>(_ block: () async throws -> Result) async throws -> Result
    func cancel() async
}

public actor TaskQueue: AsyncThrowingQueue {
    private let capacity: UInt
    private var activeCount: UInt = 0
    private var continuations = [CheckedContinuation<Void, Error>]()
    private var cancellations = [UUID: () async -> Void]()

    public init(capacity: UInt = 1) {
        self.capacity = capacity
    }
    
    public func exec<Result>(_ block: () async throws -> Result) async throws -> Result {
        if activeCount < capacity {
            activeCount += 1
            return try await _exec(block)
        }
        else {
            try await withCheckedThrowingContinuation { continuation in
                _exec(continuation: continuation)
            }
            
            return try await _exec(block)
        }
    }
    
    public func cancel() async {
        continuations.forEach { $0.resume(throwing: CancellationError()) }
        continuations.removeAll()
        for i in cancellations { await i.value() }
        cancellations.removeAll()
    }
    
    private func _exec(continuation: CheckedContinuation<Void, Error>) {
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
            return try await withoutActuallyEscaping(block) { escapedBlock in
                let id = UUID()
                let task = Task {
                    try await escapedBlock()
                }
                
                self.cancellations[id] = {
                    task.cancel()
                    _ = try? await task.value
                }
                let result = try await task.value
                
                self.cancellations[id] = nil
                return result
            }
        }
        catch {
            throw error
        }
    }
}

public actor IntervalTaskQueue: AsyncThrowingQueue {
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
            
            let result = try await block()
            self.lastExecDate = Date()
            return result
        }
    }
    
    public func cancel() async {
        await queue.cancel()
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

public struct AsyncThrowingArrayQueue: AsyncThrowingQueue {
    let array: [AsyncThrowingQueue]
    
    public init(_ array: [AsyncThrowingQueue]) {
        self.array = array
    }
    
    public func exec<Result>(_ block: () async throws -> Result) async throws -> Result {
        try await array.exec(block)
    }
    
    public func cancel() async {
        for i in array { await i.cancel() }
    }
}

public struct PriorityQueue: AsyncThrowingQueue {
    private let lowPriorityQueue = TaskQueue(capacity: 10)
    private let regularPriorityQueue = TaskQueue(capacity: 5)
    private let highPriorityQueue = TaskQueue(capacity: 2)

    private var inner: TaskQueue {
        get async {
            switch Task.currentPriority {
            case .background, .utility, .low: return lowPriorityQueue
            case .medium: return regularPriorityQueue
            case .high, .userInitiated: return highPriorityQueue
            default: assertionFailure(); return regularPriorityQueue
            }
        }
    }

    public init() {}
    
    public func exec<Result: Sendable>(_ block: () async throws -> Result)
    async throws -> Result {
        try await inner.exec(block)
    }
    
    public func cancel() async {
        await lowPriorityQueue.cancel()
        await regularPriorityQueue.cancel()
        await highPriorityQueue.cancel()
    }
}

public struct DebounceTaskQueue: AsyncThrowingQueue {
    private let debounce: IntervalTaskQueue
    private let inner: AsyncThrowingQueue
    
    public init(_ inner: AsyncThrowingQueue, interval: TimeInterval) {
        self.debounce = .init(interval: interval)
        self.inner = inner
    }
    
    public func exec<Result>(_ block: () async throws -> Result)
    async throws -> Result {
        try await debounce.exec {}
        return try await block()
    }
    
    public func cancel() async {
        await inner.cancel()
        await debounce.cancel()
    }
}

private extension Array where Element == AsyncThrowingQueue {
    func exec<Result>(_ block: () async throws -> Result) async throws -> Result {
        if self.isEmpty {
            return try await block()
        }
        else {
            var copy = self
           
            return try await copy.removeLast().exec {
                return try await copy.exec(block)
            }
        }
    }
}
