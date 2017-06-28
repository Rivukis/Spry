//
//  Argument.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

public enum Argument : CustomStringConvertible, GloballyEquatable, Equatable {
    case anything
    case nonNil
    case `nil`
    case instanceOf(type: Any.Type)

    public var description: String {
        switch self {
        case .anything:
            return "Argument.Anything"
        case .nonNil:
            return "Argument.NonNil"
        case .nil:
            return "Argument.Nil"
        case .instanceOf(let type):
            return "Argument.InstanceOf(\(type))"
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
        case (.instanceOf(let a1), .instanceOf(let b1)):
            return a1 == b1

        case (.anything, _): return false
        case (.nonNil, _): return false
        case (.nil, _): return false
        case (.instanceOf(_), _): return false
        }
    }
}

public func isEqualArgsLists(specifiedArgs: Array<GloballyEquatable>, actualArgs: Array<Any>) -> Bool {
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

private func isEqualArgs(specifiedArg: GloballyEquatable, actualArg: Any) -> Bool {
    if let passedArgAsArgumentEnum = specifiedArg as? Argument {
        switch passedArgAsArgumentEnum {
        case .anything:
            return true
        case .nonNil:
            return !isNil(actualArg)
        case .nil:
            return isNil(actualArg)
        case .instanceOf(let type):
            let cleanedType = "\(type)".replaceMatching(regex: "\\.Type+$", withString: "")
            let cleanedRecordedArgType = "\(type(of: actualArg))"

            return cleanedType == cleanedRecordedArgType
        }
    } else if let actualArg = actualArg as? GloballyEquatable {
        return specifiedArg.isEqualTo(actualArg)
    }

    fatalError("\(type(of: actualArg)) must conform to Globally Equatable")
}

private func isNil(_ value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    let hasAValue = mirror.children.first?.value != nil

    return mirror.displayStyle == .optional && !hasAValue
}

private extension String {
    func replaceMatching(regex: String, withString string: String) -> String {
        return self.replacingOccurrences(of: regex, with: string, options: .regularExpression, range: nil)
    }
}
