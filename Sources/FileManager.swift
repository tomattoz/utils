//  Created by Ivan Khvorostinin on 07.04.2025.

import Foundation

public extension FileManager {
    func isDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    func createDirectoryIfNeeded(_ url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    func tryCreateDirectoryIfNeeded(_ url: URL) {
        tryLog { try createDirectoryIfNeeded(url) }
    }
}
