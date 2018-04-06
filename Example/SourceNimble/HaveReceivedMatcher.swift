//
//  HaveReceivedMatcher.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/14/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import Nimble
import Spry

/**
 Nimble matcher used to test whether or not a function or property has been called on an object.
 
 ## Examples ##
 ```swift
 // any arguments will pass validation as long as the function was called.
 expect(service).to(haveReceived("loadJSON(url:timeout:)"))
 
 // only the first argument has to equate to the actual argument passed in.
 expect(service).to(haveReceived("loadJSON(url:)", with: URL("www.google.com")!, Argument.anything))
 
 // both arguments have to equate to the actual arguments passed in.
 expect(service).to(haveReceived("loadJSON(url:)", with: URL("www.google.com")!, 5.0))
 
 // will only pass if the function was exactly one time.
 expect(service).to(haveReceived("loadJSON(url:)", countSpecifier: .exactly(1)))
 ```
 
 - Parameter function: A string representation of the function signature
 - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
 - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
 */
public func haveReceived<T: Spyable>(_ function: T.Function, with arguments: SpryEquatable?..., countSpecifier: CountSpecifier = .atLeast(1)) -> Predicate<T> {
    return Predicate.define("") { actualExpression, msg in
        guard let spyable = try actualExpression.evaluate() else {
            let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
            return PredicateResult(status: .fail, message: .expectedActualValueTo(descriptionOfAttempted))
        }

        let descriptionOfAttempted = descriptionOfExpectation(actualType: type(of: spyable), functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
        let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)

        return PredicateResult(bool: result.success, message: .expectedCustomValueTo(descriptionOfAttempted, result.recordedCallsDescription))
    }
}

/**
 Nimble matcher used to test whether or not a function or property has been called on a class.

 ## Examples ##
 ```swift
 // any arguments will pass validation as long as the function was called.
 expect(Service).to(haveReceived("configuration()"))

 // only the first argument has to equate to the actual argument passed in.
 expect(Service).to(haveReceived("loadJSON(url:)", with: URL("www.google.com")!, Argument.anything))

 // both arguments have to equate to the actual arguments passed in.
 expect(Service).to(haveReceived("loadJSON(url:)", with: URL("www.google.com")!, 5.0))

 // will only pass if the function was exactly one time.
 expect(Service).to(haveReceived("loadJSON(url:)", countSpecifier: .exactly(1)))
 ```

 - Parameter function: A string representation of the function signature
 - Parameter arguments: Expected arguments. Will fail if the actual arguments don't equate to what is passed in here. Passing in no arguments is equivalent to passing in `Argument.anything` for every expected argument.
 - Parameter countSpecifier: Used to be more strict about the number of times this function should have been called with the passed in arguments. Defaults to .atLeast(1).
 */
public func haveReceived<T: Spyable>(_ function: T.ClassFunction, with arguments: SpryEquatable?..., countSpecifier: CountSpecifier = .atLeast(1)) -> Predicate<T.Type> {
    return Predicate.define("") { actualExpression, msg in
        guard let spyable = try actualExpression.evaluate() else {
            let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
            return PredicateResult(status: .fail, message: .expectedActualValueTo(descriptionOfAttempted))
        }

        let descriptionOfAttempted = descriptionOfExpectation(actualType: spyable, functionName: function.rawValue, arguments: arguments, countSpecifier: countSpecifier)
        let result = spyable.didCall(function, withArguments: arguments, countSpecifier: countSpecifier)

        return PredicateResult(bool: result.success, message: .expectedCustomValueTo(descriptionOfAttempted, result.recordedCallsDescription))
    }
}

// MARK: Private

private func descriptionOfExpectation(actualType: Any.Type, functionName: String, arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive <\(functionName)> on <\(actualType)>"

    if !arguments.isEmpty {
        let argumentsDescription = arguments.map { element in
            if let element = element {
                return "<\(element)>"
            } else {
                return "<nil>"
            }
            }.joined(separator: ", ")
        descriptionOfAttempt += " with \(argumentsDescription)"
    }

    let countDescription: String
    let count: Int
    switch countSpecifier {
    case .exactly(let _count):
        countDescription = "exactly"
        count = _count
    case .atLeast(let _count) where _count != 1:
        countDescription = "at least"
        count = _count
    case .atMost(let _count):
        countDescription = "at most"
        count = _count
    default:
        countDescription = ""
        count = -1
    }

    if !countDescription.isEmpty {
        let pluralism = count == 1 ? "" : "s"
        descriptionOfAttempt += " \(countDescription) \(count) time\(pluralism)"
    }

    return descriptionOfAttempt
}

private func descriptionOfNilAttempt(arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive function"

    if arguments.count != 0 {
        descriptionOfAttempt += " with arguments"
    }

    switch countSpecifier {
    case .exactly(_):
        descriptionOfAttempt += " 'count' times"
    case .atLeast(let count) where count != 1:
        descriptionOfAttempt += " at least 'count' times"
    case .atMost(_):
        descriptionOfAttempt += " at most 'count' times"
    default: break
    }

    return descriptionOfAttempt
}
