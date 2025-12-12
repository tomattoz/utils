//  Created by Ivan Kh on 10.10.2024.

import Foundation

public protocol TechnicalError: Error {
    var technicalDescription: String { get }
}

public protocol DisplayError: Error {
    var displayDescription: String { get }
}

public extension Error {
    var friendlyTitle: String? {
        (self as NSError).what
    }
    
    var friendlyDescription: String {
        if let error = self as? DisplayError {
            return error.displayDescription
        }
        
        if let error = self as? LocalizedError {
            return error.errorDescription ?? error.localizedDescription
        }
        
        if !(self as NSError).userInfo.isEmpty, let why = (self as NSError).why, !why.isEmpty {
            return why
        }

        return (self as CustomStringConvertible).description
    }
    
    var techDescription: String {
        if let error = self as? TechnicalError {
            return error.technicalDescription
        }

        if let error = self as? LocalizedError {
            return (error.errorDescription ?? error.localizedDescription)
        }
        
        if let error = self as? Codable {
            if let data = try? JSONEncoder().encode(error),
                let string = String(data: data, encoding: .utf8) {
                return String(describing: self) + ". JSON " + string
            }
            else {
                return String(describing: self)
            }
        }

        return (self as CustomStringConvertible).description
    }
}

public struct StringError: Error, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
}

public struct ErrorDescription: Error, LocalizedError {
    public let inner: Error
    public let description: String
    
    public init(inner: Error, description: String) {
        self.inner = inner
        self.description = description
    }
    
    public var errorDescription: String? {
        description
    }
}

public protocol AdditionalInfoError {
    var additionalInfo: [String: String] { get }
}

extension NSError: AdditionalInfoError {
    public var additionalInfo: [String : String] {
        userInfo.compactMapValues { $0 as? String }
    }
}

private extension NSError {
    var underlying: NSError? {
        return userInfo[NSUnderlyingErrorKey] as? NSError
    }

    var what: String? {
        localizedFailureReason ?? underlying?.what
    }

    var why: String? {
        if let result = self.userInfo[NSLocalizedDescriptionKey] as? String {
            return result
        }
        else if let result = self.userInfo[NSLocalizedFailureErrorKey] as? String {
            return result
        }
        else {
            return underlying?.why
        }
    }

    var how: String? {
        localizedRecoverySuggestion ?? underlying?.how
    }
}

public enum Error9: Error {
    case unsupported
    case jsonEncode(String)
    case jsonDecode(String)
    case stringData(String)
    case stringFromData(Data)
}

public extension Error9 {
    struct Timeout: Error {
        public init() {}
    }
}
