//  Created by Ivan Kh on 30.09.2025.

import Foundation

public extension JSONEncoder {
    func encodeAsString<T>(_ value: T) throws -> String where T : Encodable {
        let data: Data = try encode(value)
        
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        else {
            throw Error9.stringFromData(data)
        }
    }
}

public extension JSONDecoder {
    func decode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable {
        guard let data = string.data(using: .utf8) else {
            throw Error9.stringData(string)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

