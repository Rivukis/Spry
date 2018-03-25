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

 - Important: Never manually implement `_isEqual(to:)` when conform to `SpryEquatable`. Instead rely on the provided extensions.
 - Note: If a compiler error says you do NOT conform to `SpryEquatable` then conform to `Equatable`. This will remove the error.
 */
public protocol SpryEquatable {
    func _isEqual(to actual: SpryEquatable?) -> Bool
}

public extension SpryEquatable {
    func _isEqual(to actual: SpryEquatable?) -> Bool {
        Constant.FatalError.doesNotConformToEquatable(self)
    }
}

// MARK: - SpryEquatable where Self: Equatable

public extension SpryEquatable where Self: Equatable {
    func _isEqual(to actual: SpryEquatable?) -> Bool {
        guard let castedActual = actual as? Self else {
            return false
        }

        return self == castedActual
    }
}

// MARK: - SpryEquatable where Self: AnyObject

public extension SpryEquatable where Self: AnyObject {
    func _isEqual(to actual: SpryEquatable?) -> Bool {
        guard let castedActual = actual as? Self else {
            return false
        }

        return self === castedActual
    }
}

// MARK: - SpryEquatable where Self: AnyObject & Equatable

public extension SpryEquatable where Self: AnyObject & Equatable {
    func _isEqual(to actual: SpryEquatable?) -> Bool {
        guard let castedActual = actual as? Self else {
            return false
        }

        return self == castedActual
    }
}

// MARK: - SpryEquatable for Arrays

public extension Array {
    func _isEqual(to actual: SpryEquatable?) -> Bool {
        guard let castedActual = actual as? Array<Element> else {
            return false
        }

        if self.count != castedActual.count {
            return false
        }

        return zip(self, castedActual).reduce(true) { result, zippedElements in
            if !result {
                return false
            }

            if let selfElement = zippedElements.0 as? SpryEquatable, let actualElement = zippedElements.1 as? SpryEquatable {
                return selfElement._isEqual(to: actualElement)
            }

            Constant.FatalError.doesNotConformToSpryEquatable(zippedElements.0)
        }
    }
}

// MARK: - SpryEquatable for Dictionaries

public extension Dictionary {
    func _isEqual(to actual: SpryEquatable?) -> Bool {
        guard let castedActual = actual as? Dictionary<Key, Value> else {
            return false
        }

        if self.count != castedActual.count {
            return false
        }

        for (key, value) in self {
            guard castedActual.has(key: key), let actualValue = castedActual[key] else {
                return false
            }

            guard let castedValue = value as? SpryEquatable, let castedActualValue = actualValue as? SpryEquatable else {
                Constant.FatalError.doesNotConformToSpryEquatable(value)
            }

            if !castedValue._isEqual(to: castedActualValue) {
                return false
            }
        }

        return true
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
    public func _isEqual(to actual: SpryEquatable?) -> Bool {
        let selfMirror = Mirror(reflecting: self)

        guard selfMirror.displayStyle == .optional else {
            Constant.FatalError.shouldNotConformToOptionalType(self)
        }

        guard type(of: self) == type(of: actual) else {
            return false
        }

        let selfsWrappedValue = selfMirror.children.first?.value

        if isNil(selfsWrappedValue) && isNil(actual) {
            return true
        }
        guard let selfsWrappedValueAsNonOptional = selfsWrappedValue, let actual = actual else {
            return false
        }

        guard let selfsContainedValueAsSE = selfsWrappedValueAsNonOptional as? SpryEquatable else {
            Constant.FatalError.doesNotConformToSpryEquatable(selfsWrappedValue!)
        }

        return selfsContainedValueAsSE._isEqual(to: actual)
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
