//  Created by Ivan Kh on 10.10.2024.

import Foundation

public protocol TechnicalError: Error {
    var technicalDescription: String { get }
}

public protocol DisplayError: Error {
    var displayDescription: String { get }
}

public extension Error {
    var friendlyDescription: String {
        if let error = self as? DisplayError {
            return error.displayDescription
        }
        
        if let error = self as? LocalizedError {
            return error.errorDescription ?? error.localizedDescription
        }

        return (self as CustomStringConvertible).description
    }
    
    var techDescription: String {
        if let error = self as? TechnicalError {
            return error.technicalDescription
        }

        if let error = self as? LocalizedError {
            return "[case0] " + (error.errorDescription ?? error.localizedDescription)
        }
        
        if let error = self as? Codable {
            if let data = try? JSONEncoder().encode(error),
                let string = String(data: data, encoding: .utf8) {
                return "[case1] " + String(describing: self) + ". JSON " + string
            }
            else {
                return "[case2] " + String(describing: self)
            }
        }

        return "[case3] " + (self as CustomStringConvertible).description
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

public enum Error9: Error {
    case unsupported
    case jsonEncode(String)
    case jsonDecode(String)
    case stringData(String)
}
