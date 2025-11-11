//  Created by Ivan Kh on 30.09.2025.

import Foundation

public extension Encodable {
    var asJsonString: String? {
        let encoder = JSONEncoder()
        
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
