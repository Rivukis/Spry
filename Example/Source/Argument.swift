//
//  Argument.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/3/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

/**
 Used to capture an argument for more detailed testing on an argument.
 */
class ArgumentCaptor: SpryEquatable {
    private var capturedArguments: [Any?] = []

    /**
     Get an argument that was captured.

     - Parameter at: The index of the captured argument. The index cooresponds the number of times the specified function was called (when argument specifiers passed validation). For instance if the function was called 5 times and you want the argument captured during the 2nd call then ask for index 1, `getValue(at: 1)`. Defaults to 0. Asking for the an index that is out of bounds will result in a `fatalError()`.
     - Parameter as: The expected type of the argument captured. Asking for the wrong type will result in a `fatalError()`

     - Returns: The captured argument or fatal error if there was an issue.
     */
    func getValue<T>(at index: Int = 0, as: T.Type = T.self) -> T {
        guard index >= 0 && capturedArguments.count > index else {
            fatalError("index <\(index)> is out of bounds for captured arguments count of <\(capturedArguments.count)>")
        }

        let capturedAsUnknownType = capturedArguments[index]
        guard let captured = capturedAsUnknownType as? T else {
            fatalError("Could not cast captured argument <\(String(describing: capturedAsUnknownType))> to type <\(T.self)>")
        }

        return captured
    }

    func capture(_ argument: Any?) {
        capturedArguments.append(argument)
    }
}

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
    case pass((Any?) -> Bool)

    public var description: String {
        switch self {
        case .anything:
            return "Argument.anything"
        case .nonNil:
            return "Argument.nonNil"
        case .nil:
            return "Argument.nil"
        case .pass(_):
            return "Argument.pass"
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
        case (.pass(_), .pass(_)):
            return true

        case (.anything, _): return false
        case (.nonNil, _): return false
        case (.nil, _): return false
        case (.pass(_), _): return false
        }
    }

    /**
     Convenience function to get an `ArgumentCapture`. Used when stubbing to capture the actual arguments. Used for more detailed testing on arguments being passed into a `Stubbable`

     - SeeAlso: `ArgumentCapture`

     - Returns: A new ArgumentCapture.
     */
    static func captor() -> ArgumentCaptor {
        return ArgumentCaptor()
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
            return !isNil(actualArg)
        case .nil:
            return isNil(actualArg)
        case .pass(let validator):
            return validator(actualArg)
        }
    }

    if specifiedArg is ArgumentCaptor {
        return true
    }

    guard let specifiedArgReal = specifiedArg, let actualArgReal = actualArg else {
        return isNil(specifiedArg) && isNil(actualArg)
    }

    guard let actualArgRealAsSE = actualArgReal as? SpryEquatable else {
        fatalError("\(type(of: actualArgReal)) must conform to Spry Equatable")
    }

    return specifiedArgReal.isEqual(to: actualArgRealAsSE)
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
