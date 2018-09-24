//
//  HaveRecordedCallsMatcher.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 3/25/18.
//  Copyright © 2018 Brian Radebaugh. All rights reserved.
//

import Nimble
import Spry

/**
 Nimble matcher used to determine if at least one call has been made.

 - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
 */
public func haveRecordedCalls<T: Spyable>() -> Predicate<T> {
    return Predicate.define("have recorded calls") { actualExpression, msg in
        guard let spyable = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        let success = !spyable._callsDictionary.calls.isEmpty
        let message: ExpectationMessage = .expectedCustomValueTo(
            msg.expectedMessage,
            descriptionOfActual(count: spyable._callsDictionary.calls.count)
        )
        
        return PredicateResult(bool: success, message: message)
    }
}

/**
 Nimble matcher used to determine if at least one call has been made.

 - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
 */
public func haveRecordedCalls<T: Spyable>() -> Predicate<T.Type> {
    return Predicate.define("have recorded calls") { actualExpression, msg in
        guard let spyable = try actualExpression.evaluate() else {
            return PredicateResult(status: .fail, message: msg)
        }

        let success = !spyable._callsDictionary.calls.isEmpty
        let message: ExpectationMessage = .expectedCustomValueTo(
            msg.expectedMessage,
            descriptionOfActual(count: spyable._callsDictionary.calls.count)
        )

        return PredicateResult(bool: success, message: message)
    }
}

// MARK: - Private Helpers

private func descriptionOfActual(count: Int) -> String {
    let pluralism = count == 1 ? "" : "s"
    return "\(count) call\(pluralism)"
}
