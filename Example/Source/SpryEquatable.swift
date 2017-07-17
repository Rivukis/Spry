//
//  SpryEquatable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 4/2/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 Used to compare any two arguments. Uses Equatable's `==(lhs:rhs:)` operator for comparision.

 - Important: Never manually conform to `SpryEquatable`.
 - Note: If a compiler error says you do NOT conform to `SpryEquatable` then conform to `Equatable`. This will remove the error.
 */
public protocol SpryEquatable {
    func isEqual(to actual: SpryEquatable?) -> Bool
}

public extension SpryEquatable {
    func isEqual(to actual: SpryEquatable?) -> Bool {
        fatalError("\(type(of: self)) does NOT conform to Equatable. Conforming to Equatable is required for SpryEquatable.")
    }
}

// MARK: - SpryEquatable where Self: Equatable

public extension SpryEquatable where Self: Equatable {
    func isEqual(to actual: SpryEquatable?) -> Bool {
        if let actual = actual as? Self {
            return self == actual
        }

        return false
    }
}

// MARK: - SpryEquatable for Arrays

public extension Array {
    func isEqual(to actual: SpryEquatable?) -> Bool {
        if let actual = actual as? Array<Element> {
            if self.count != actual.count {
                return false
            }

            return zip(self, actual).reduce(true) {
                if !$0 {
                    return false
                }

                if let selfElement = $1.0 as? SpryEquatable, let actualElement = $1.1 as? SpryEquatable {
                    return selfElement.isEqual(to: actualElement)
                }

                fatalError("\(type(of: $1.0)) does NOT conform to SpryEquatable")
            }
        }

        return false
    }
}

// MARK: - SpryEquatable for Dictionarys

public extension Dictionary {
    func isEqual(to actual: SpryEquatable?) -> Bool {
        if let actual = actual as? Dictionary<Key, Value> {
            if self.count != actual.count {
                return false
            }

            return zip(self, actual).reduce(true) {
                if !$0 {
                    return false
                }

                guard let selfKey = $1.0.key as? SpryEquatable, let actualKey = $1.1.key as? SpryEquatable else {
                    fatalError("\(type(of: $1.0.key)) does NOT conform to SpryEquatable")
                }

                guard let selfValue = $1.0.value as? SpryEquatable, let actualValue = $1.1.value as? SpryEquatable else {
                    fatalError("\(type(of: $1.0.value)) does NOT conform to SpryEquatable")
                }

                return selfKey.isEqual(to: actualKey) && selfValue.isEqual(to: actualValue)
            }
        }

        return false
    }
}

// MARK: - OptionalType

/**
 Used to specify an `Optional` constraint. This is needed until Swift supports extensions where Self can be constrained to a type.
 */
public protocol OptionalType {}
extension Optional: OptionalType {}

// MARK: - SpryEquatable where Self: OptionalType

public extension SpryEquatable where Self: OptionalType {
    public func isEqual(to actual: SpryEquatable?) -> Bool {
        let selfMirror = Mirror(reflecting: self)

        guard selfMirror.displayStyle == .optional else {
            fatalError("\(type(of: self)) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
        }

        let selfsWrappedValue = selfMirror.children.first?.value

        if isNil(selfsWrappedValue) && isNil(actual) {
            return true
        }
        guard let selfsWrappedValueAsNonOptional = selfsWrappedValue, let actual = actual else {
            return false
        }

        guard let selfsContainedValueAsSE = selfsWrappedValueAsNonOptional as? SpryEquatable else {
            fatalError("\(type(of: selfsWrappedValue)) does NOT conform to SpryEquatable")
        }

        return selfsContainedValueAsSE.isEqual(to: actual)
    }
}

// MARK: - Default Conformers
extension Optional: SpryEquatable {}
extension String: SpryEquatable {}
extension Int: SpryEquatable {}
extension Double: SpryEquatable {}
extension Bool: SpryEquatable {}
extension Array: SpryEquatable {}
extension Dictionary: SpryEquatable {}
extension NSObject: SpryEquatable {}
