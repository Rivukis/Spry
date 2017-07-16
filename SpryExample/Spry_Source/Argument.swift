//
//  Argument.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/3/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

/**
 Argument specifier used by Spyable and Stubbable. Used for non-Equatable comparision.
 
 * .anything - Every value matches this qualification.
 * .nonNil - Every value matches this qualification except Optional.none
 * .nil - Only Optional.nil matches this qualification.
 * .instanceOf(type:) - Only objects whose type is exactly the type passed in match this qualification (subtypes do NOT qualify).
 */
public enum Argument: CustomStringConvertible, SpryEquatable, Equatable {
    case anything
    case nonNil
    case `nil`

    public var description: String {
        switch self {
        case .anything:
            return "Argument.Anything"
        case .nonNil:
            return "Argument.NonNil"
        case .nil:
            return "Argument.Nil"
        }
    }

    public static func == (lhs: Argument, rhs: Argument) -> Bool {
        switch (lhs, rhs) {
        case (.anything, .anything):
            return true
        case (.nonNil, .nonNil):
            return true
        case (.nil, .nil):
            return true

        case (.anything, _): return false
        case (.nonNil, _): return false
        case (.nil, _): return false
        }
    }
}

internal func isEqualArgsLists(specifiedArgs: [SpryEquatable?], actualArgs: [Any?]) -> Bool {
    if specifiedArgs.count != actualArgs.count {
        return false
    }

    for index in 0..<actualArgs.count {
        let specifiedArg = specifiedArgs[index]
        let actualArg = actualArgs[index]

        if !isEqualArgs(specifiedArg: specifiedArg, actualArg: actualArg) {
            return false
        }
    }

    return true
}

private func isEqualArgs(specifiedArg: SpryEquatable?, actualArg: Any?) -> Bool {
    if let passedArgAsArgumentEnum = specifiedArg as? Argument {
        switch passedArgAsArgumentEnum {
        case .anything:
            return true
        case .nonNil:
            return actualArg != nil
        case .nil:
            return actualArg == nil
        }
    }

    if specifiedArg == nil && actualArg == nil {
        return true
    }

    guard let specifiedArgReal = specifiedArg, let actualArgReal = actualArg else {
        return specifiedArg == nil && actualArg == nil
    }

    guard let actualArgRealAsSE = actualArgReal as? SpryEquatable else {
        fatalError("\(type(of: actualArgReal)) must conform to Spry Equatable")
    }

    return specifiedArgReal.isEqual(to: actualArgRealAsSE)
}
