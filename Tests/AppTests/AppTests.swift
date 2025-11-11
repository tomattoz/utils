import Testing
@testable import Utils9

struct TestObject {
    func foo() async throws {}
}

struct Tests {
    @Test func taskQueue() async throws {
        let taskQueue = TaskQueue(capacity: 1)
        
        await withThrowingTaskGroup(of: Void.self) { group in
            var count = 0
            
            for i in 0 ..< 100000 {
                group.addTask {
                    try await taskQueue.exec {
                        print("\(i)")
                                                                        
                        if i % 2 == 1 {
                            throw Error9.unsupported
                        }
                        else {
                            count += 1
                        }
                    }
                }
            }
            
            try? await group.waitForAll()
            #expect(count == 50000)
        }
    }

    @Test func taskAccessQueue() async throws {
        let queue = AccessQueue([TestObject(), TestObject(), TestObject(), TestObject(), TestObject()])
        
        try await withThrowingTimeout9(seconds: 10) {
            await withThrowingTaskGroup(of: Void.self) { group in
                for i in 0 ..< 100 {
                    group.addTask {
                        try await queue.exec {
                            print("\(i)")
                            try await $0.foo()
                        }
                    }
                }
                
                group.addTask {
                    for i in 0 ..< 100 {
                        try await queue.exec {
                            print("\(i)")
                            try await $0.foo()
                        }
                    }
                }
                
                try? await group.waitForAll()
            }
        }
    }
}
