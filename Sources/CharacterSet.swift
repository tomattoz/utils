//  Created by Ivan Khvorostinin on 05.04.2025.

import Foundation

public extension CharacterSet {
    func contains(_ character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}

