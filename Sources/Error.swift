//  Created by Ivan Kh on 10.10.2024.

import Foundation

public extension Error {
    var friendlyDescription: String {
        if let error = self as? LocalizedError {
            return error.errorDescription ?? error.localizedDescription
        }
        else {
            return (self as CustomStringConvertible).description
        }
    }
    
    var techDescription: String {
        if let error = self as? LocalizedError {
            return "[case0] " + (error.errorDescription ?? error.localizedDescription)
        }
        else if let error = self as? Codable {
            if let data = try? JSONEncoder().encode(error),
                let string = String(data: data, encoding: .utf8) {
                return "[case1] " + String(describing: self) + ". JSON " + string
            }
            else {
                return "[case2] " + String(describing: self)
            }
        }
        else {
            return "[case3] " + (self as CustomStringConvertible).description
        }
    }
}

public struct StringError: Error, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
}

struct ErrorDescription: Error, LocalizedError {
    let inner: Error
    let description: String
    
    init(inner: Error, description: String) {
        self.inner = inner
        self.description = description
    }
    
    var errorDescription: String? {
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
