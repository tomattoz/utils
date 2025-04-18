//  Created by Ivan Khvorostinin on 07.04.2025.

import Foundation

public extension URL {
    var isHidden: Bool {
        tryLog { try resourceValues(forKeys: [.isHiddenKey]).isHidden } == true
    }
    
    var isDirectory: Bool {
        tryLog { try resourceValues(forKeys: [.isDirectoryKey]).isDirectory } == true
    }
}
