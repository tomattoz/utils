//  Created by Ivan Khvorostinin on 25.06.2025.

import Foundation

prefix operator ~

public prefix func ~ (string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

public extension String {
    static func randomLetters(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    var trimmingForFloat: String {
        trimmingCharacters(in: .decimalDigits
            .union(.punctuationCharacters)
            .inverted)
    }
    
    mutating func trimCharacters(in set: CharacterSet) {
        self = self.trimmingCharacters(in: set)
    }

    mutating func trimPrefix(until string: String) {
        guard !string.isEmpty else { return }
       
        if let r = self.range(of: string) {
            self = String(self[r.lowerBound...])
        } else {
            self = ""
        }
    }

    func trimmingPrefix(in characterSet: CharacterSet) -> String {
        var result = self
        while let firstCharacter = result.first, characterSet.contains(firstCharacter.unicodeScalars.first!) {
            result.removeFirst()
        }
        return result
    }
    
    func trimmingSuffix(in characterSet: CharacterSet) -> String {
        var result = self
        while let lastCharacter = result.last, characterSet.contains(lastCharacter.unicodeScalars.first!) {
            result.removeLast()
        }
        return result
    }

    func substring9(from index: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[startIndex...])
    }

    func removing(at i: String.Index) -> Self {
        var result = self
        result.remove(at: i)
        return result
    }

    func removingFirst(_ k: Int = 1) -> Self {
        var result = self
        result.removeFirst(k)
        return result
    }

    func removingLast(_ k: Int = 1) -> Self {
        var result = self
        result.removeLast(k)
        return result
    }
}
