//  Created by Ivan Khvorostinin on 07.04.2025.

import Foundation

public extension URL {
    var isHidden: Bool {
        tryLog { try resourceValues(forKeys: [.isHiddenKey]).isHidden } == true
    }
    
    var isDirectory: Bool {
        tryLog { try resourceValues(forKeys: [.isDirectoryKey]).isDirectory } == true
    }
    
    var queryParameters: [String: String] {
        var parameters: [String: String] = [:]

        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return parameters
        }
        
        for queryItem in queryItems {
            if let value = queryItem.value {
                parameters[queryItem.name] = value
            }
        }
        
        return parameters
    }
}
