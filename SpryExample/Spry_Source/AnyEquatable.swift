//
//  SpryEquatable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 4/2/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

/**
 Used to compare any two arguments. Uses Equatable's `==(lhs:rhs:)` operator for comparision.
 
 - Important: Never manually conform to `SpryEquatable`.
 - Note: If a compiler error says you do NOT conform to `SpryEquatable` then conform to `Equatable`. This will remove the error.
 */
public protocol SpryEquatable {
    func isEqual(to actual: SpryEquatable?) -> Bool
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
            assertionFailure("\(type(of: self)) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }

        let selfsWrappedValue = selfMirror.children.first?.value

        if selfsWrappedValue == nil && actual == nil {
            return true
        }
        guard let selfsWrappedValueAsNonOptional = selfsWrappedValue, let actual = actual else {
            return false
        }

        guard let selfsContainedValueAsSE = selfsWrappedValueAsNonOptional as? SpryEquatable else {
            assertionFailure("\(type(of: selfsWrappedValue)) does NOT conform to SpryEquatable")
            return false
        }

        return selfsContainedValueAsSE.isEqual(to: actual)
    }
}
