//  Created by Ivan Kh on 28.08.2023.

import Foundation

public class Logger {
    public enum Flow {
        case debug
        case release
    }
    
    public static let shared = Logger()
    
    private var _additionalInfo = [String: () -> String?]()
    private var _adapters = LockedVar([Flow: [LogAdapter]]())
    private let flow: Flow
    
    init() {
        #if DEBUG
        flow = .debug
        #else
        flow = .release
        #endif
    }
    
    public var additionalInfo: [String: String] {
        _additionalInfo.reduce([String: String]()) { result, data in
            if let value = data.value() {
                var result = result
                result[data.key] = value
                return result
            }
            else {
                return result
            }
        }
    }
    
    public func register(for key: String, additional info: @escaping () -> String?) {
        _additionalInfo[key] = info
    }
    
    public func register(for key: String, additional info: String) {
        _additionalInfo[key] = { info }
    }

    public func register(for flow: Flow, provider: LogAdapter) {
        if _adapters.value[flow] == nil {
            _adapters.value[flow] = [LogAdapter]()
        }
        
        _adapters.value[flow]?.append(provider)
    }

    func set(property: String, for key: String) {
        _adapters.value[flow]?.forEach { $0.set(property: property, for: key) }
    }
    
    func log(error: Error, info: String?) {
        _adapters.value[flow]?.forEach { $0.log(error: error, info: info) }
    }
    
    func log(event: String, parameters: [String: String]) {
        _adapters.value[flow]?.forEach { $0.log(event: event, parameters: parameters) }
    }
    
    func log(info: String) {
        _adapters.value[flow]?.forEach { $0.log(info: info) }
    }
    
    func log(warning: String) {
        _adapters.value[flow]?.forEach { $0.log(warning: warning) }
    }
}

public protocol LogAdapter {
    func log(error: Error, info: String?)
    func log(event: String, parameters: [String: String])
    func log(warning: String)
    func log(info: String)
    func set(property: String, for key: String)
}

public struct StdoutLogger: LogAdapter {
    public init() {
    }
    
    public func log(error: Error, info: String?) {
        let description = error.techDescription
        
        if let info {
            print("🔴 \(description) [\(info)]")
        }
        else {
            print("🔴 \(description)")
        }
    }
    
    public func log(event: String, parameters: [String: String]) {
        print("🟣 \(event)")
    }
    
    public func log(warning: String) {
        print("🟠 \(warning)")
    }
    
    public func log(info: String) {
        print("🔵 \(info)")
    }

    public func set(property: String, for key: String) {
        print("ℹ️ \(key): \(property)")
    }
}

public func log(error: String) {
    log(StringError(error))
}

public func log(_ error: Error?, info: String? = nil) {
    guard let error else { return }
    Logger.shared.log(error: error, info: info)
}

public func log(event: String, parameters: [String: String] = [:]) {
    Logger.shared.log(event: event, parameters: parameters)
}

public func log(_ info: String) {
    Logger.shared.log(info: info)
}

public func log(warning: String) {
    Logger.shared.log(warning: warning)
}

public func log(warning: Error) {
    Logger.shared.log(warning: warning.techDescription)
}

public func tryLog<T>(_ block: () throws -> T) -> T? {
    do {
        return try block()
    }
    catch {
        log(error)
    }

    return nil
}

public func tryLog<T>(_ block: () throws -> T?) -> T? {
    do {
        return try block()
    }
    catch {
        log(error)
    }

    return nil
}

public func tryLog<T>(_ block: () async throws -> T) async -> T? {
    do {
        return try await block()
    }
    catch {
        log(error)
    }

    return nil
}

public func tryLog<T>(_ block: () async throws -> T?) async -> T? {
    do {
        return try await block()
    }
    catch {
        log(error)
    }

    return nil
}

public func set(property: String, for key: String) {
    Logger.shared.set(property: property, for: key)
}
