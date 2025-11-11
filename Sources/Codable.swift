//  Created by Ivan Kh on 30.09.2025.

import Foundation

public extension String {
    init(encodable src: Encodable) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(src)
        
        if let string = String(data: data, encoding: .utf8) {
            self = string
        }
        else {
            throw Error9.stringFromData(data)
        }
    }
}

public extension Decodable {
    init(string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw Error9.stringData(string)
        }
        
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

