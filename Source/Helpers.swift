//
//  Helpers.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/9/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

// MARK: - Optional Extensions

internal extension Optional {
    func stringRepresentation() -> String {
        switch self {
        case .some(let wrapped):
            return String(describing: wrapped)
        case .none:
            return "nil"
        }
    }
}

/**
 This is a helper function to find out if a value is nil.

 (x == nil) will only return yes if x is Optional<Type>.none but will return true if x is Optional<Optional<Type\>>.some(Optional<Type>.none)
 */
internal func isNil(_ value: Any?) -> Bool {
    if let unwrappedValue = value {
        let mirror = Mirror(reflecting: unwrappedValue)
        if mirror.displayStyle == .optional {
            return isNil(mirror.children.first)
        }
        return false
    } else {
        return true
    }
}

// MARK: - Bool Extensions

internal extension Bool {
    func toInt() -> Int {
        return self ? 1 : 0
    }
}

// MARK: - String Extensions

extension String {
    func removeAfter(startingCharacter character: String) -> String? {
        let range = self.range(of: character)
        if let lowerBound = range?.lowerBound {
            return String(self[..<lowerBound])
        }

        return nil
    }
}

// MARK: - Array Extensions

internal extension Array {
    /**
     Splits the array into two separate arrays.

     - Parameter closure: The closure to determine which array each element will be put into. Return `true` to put item in first array and `false` to put it into the second array.
     */
    func bisect(_ closure: (Element) -> Bool) -> ([Element], [Element]) {
        var arrays = ([Element](), [Element]())
        self.forEach { closure($0) ? arrays.0.append($0) : arrays.1.append($0) }

        return arrays
    }
}

internal extension Array where Element: Equatable {
    @discardableResult mutating func removeFirst(_ element: Element) -> Element? {
        guard let index = index(of: element) else {
            return nil
        }

        return remove(at: index)
    }
}

internal extension Array {
    @discardableResult mutating func removeFirst(where predicate: (Element) -> Bool) -> Element? {
        guard let index = index(where: predicate) else {
            return nil
        }

        return remove(at: index)
    }
}

// MARK: - Dictionary Extensions

internal extension Dictionary {
    func has(key: Key) -> Bool {
        return self.contains { $0.key == key }
    }
}
