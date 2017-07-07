//
//  AnyEquatable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 4/2/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

/**
 Used to conpare any two arguments. Uses Equatable's `==(lhs:rhs:)` operator for conparision.
 
 - Important: Never manually conform to `AnyEquatable`.
 - Note: If a compiler error says you do NOT conform to `AnyEquatable` then conform to `Equatable`. This will remove the error.
 */
public protocol AnyEquatable {
    func isEqual(to other: AnyEquatable) -> Bool
}

/**
 Default implementation for `AnyEquatable` when `Self` is `Equatable`.
 */
public extension AnyEquatable where Self: Equatable {
    public func isEqual(to other: AnyEquatable) -> Bool {
        // if 'self' is non-optional and 'other' is optional and other's .Some's associated value's type equals self's type
        // then the if let below will auto unwrap 'other' to be the non-optional version of self's type
        if type(of: self) != type(of: other) {
            return false
        }

        if let other = other as? Self {
            return self == other
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

/**
 Default implementation for `AnyEquatable` when `Self` is `OptionalType` (aka `Optional`).
 */
public extension AnyEquatable where Self: OptionalType {
    public func isEqual(to other: AnyEquatable) -> Bool {
        if type(of: self) != type(of: other) {
            return false
        }

        let selfMirror = Mirror(reflecting: self)
        let otherMirror = Mirror(reflecting: other)

        guard selfMirror.displayStyle == .optional else {
            assertionFailure("\(type(of: self)) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }
        guard otherMirror.displayStyle == .optional else {
            assertionFailure("\(type(of: other)) should NOT conform to OptionalType, this is reserved for Optional<Wrapped>")
            return false
        }

        let selfsWrappedValue = selfMirror.children.first?.value
        let othersWrappedValue = otherMirror.children.first?.value

        if selfsWrappedValue == nil && othersWrappedValue == nil {
            return true
        }
        guard let selfsWrappedValueNonOptional = selfsWrappedValue, let othersWrappedValueNonOptional = othersWrappedValue else {
            return false
        }

        guard let selfsContainedValueAsGE = selfsWrappedValueNonOptional as? AnyEquatable else {
            assertionFailure("\(type(of: selfsWrappedValue)) does NOT conform to AnyEquatable")
            return false
        }
        guard let othersContainedValueAsGE = othersWrappedValueNonOptional as? AnyEquatable else {
            assertionFailure("\(type(of: othersWrappedValue)) does NOT conform to AnyEquatable")
            return false
        }

        return selfsContainedValueAsGE.isEqual(to: othersContainedValueAsGE)
    }
}
