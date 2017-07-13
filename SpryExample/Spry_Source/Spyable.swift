//
//  Spyable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/1/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import Foundation

// MARK: - Public Helper Objects

/**
 Used internally. Should never need to use or know about this type.

 * function: String - The function signature of a recorded call. Defaults to `#function`.
 * arguments: [Any] - The arguments passed in when the function was recorded.
 */
public class RecordedCall: CustomStringConvertible {
    let function: String
    let arguments: [Any]

    internal init(function: String, arguments: [Any]) {
        self.function = function
        self.arguments = arguments
    }

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        return "RecordedCall(function: <\(function)>, arguments: <\(arguments.map{"<\($0)>"}.joined(separator: ", ")))>"
    }
}

/**
 The resulting information when using the `didCall()` function.

 * success: Bool - `true` if the function was called given the criteria specified, otherwise `false`.
 * recordedCallsDescription: String - A list of all recorded calls. Helpful information if success if `false`.
 */
public struct DidCallResult {
    public let success: Bool
    public let recordedCallsDescription: String

    internal init(success: Bool, recordedCallsDescription: String) {
        self.success = success
        self.recordedCallsDescription = recordedCallsDescription
    }
}

/**
 Used when specifying if a function was called.

 * .exactly - Will only succeed if the function was called exactly the number of times specified.
 * .atLeast - Will only succeed if the function was called the number of times specified or more.
 * .atMost - Will only succeed if the function was called the number of times specified or less.
 */
public enum CountSpecifier {
    case exactly(Int)
    case atLeast(Int)
    case atMost(Int)
}

/**
 A protocol used to spy on an object's function calls. A small amount of boilerplate is requried.
 
 - Important: All the functions specified in this protocol come with default implementation that should NOT be overridden.
 
 - Note: The `Spryable` protocol exists as a convenience when conforming to both `Spyable` and `Stubbable`.
 
 * var _calls: [RecordedCall] - Used internally to keep track of recorded calls.
 * recoredCall(function: String, arguments: Any...) - Used to record a call.
 * clearRecordedLists() - Used to clear out all recorded calls.
 * didCall(function: String, withArguments arguments: [AnyEquatable], countSpecifier: CountSpecifier) -> DidCallResult - Used to find out if a call was made.
 */
public protocol Spyable: class {
    /**
     This is where the recorded calls are held.
     
     Should ONLY read from this property when debugging.
     
     - Important: Do not modify this property's value.
     
     ## Example Conformance ##
     ```swift
     var _calls: [RecordedCall] = []
     ```
     */
    var _calls: [RecordedCall] { get set }

    /**
     Used to record a function call. Must call in every function for Spyable to work properly.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature to be recorded. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Spyable to work properly.
     */
    func recordCall(function: String, arguments: Any...)

    /**
     Used to clear out all recorded function calls.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The spied object will have NO way of knowing about calls made before this function is called. Use with caution.
     */
    func clearRecordedLists()

    /**
     Used to determine if a function has been called with the specified arguments and with the amount of times specified.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.
     - Important: Only use this function if NOT using the provided `haveReceived()` matcher used in conjunction with [Quick/Nimble](https://github.com/Quick).

     - Parameter function: The function signature as a `String`.
     - Parameter arguments: The arguments specified. If this value is an empty array, then any parameters passed into the actual function call will result in a success (i.e. passing in `[]` is equivalent to passing in Argument.anything for every expected parameter.)
     - Parameter countSpecifier: Used to specify the amount of times this function needs to be called for a successful result. See `CountSpecifier` for more detials.
     
     - Returns: A DidCallResult. See `DidCallResult` for more details.
     */
    func didCall(function: String, withArguments arguments: [AnyEquatable], countSpecifier: CountSpecifier) -> DidCallResult
}

// MARK - Spyable Extension

public extension Spyable {
    func recordCall(function: String = #function, arguments: Any...) {
        internal_recordCall(function: function, arguments: arguments)
    }

    func clearRecordedLists() {
        _calls = []
    }
    
    func didCall(function: String, withArguments arguments: [AnyEquatable] = [], countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
        case .exactly(let count): success = timesCalled(function, arguments: arguments) == count
        case .atLeast(let count): success = timesCalled(function, arguments: arguments) >= count
        case .atMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }

        let recordedCallsDescription = description(of: _calls)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }

    // MARK: - Internal Functions

    /// This is for `Spryable` to act as a pass-through to record a call.
    internal func internal_recordCall(function: String, arguments: [Any]) {
        let call = RecordedCall(function: function, arguments: arguments)
        _calls.append(call)
    }

    // MARK: - Private Functions
    
    private func timesCalled(_ function: String, arguments: [AnyEquatable]) -> Int {
        return numberOfMatchingCalls(function: function, arguments: arguments, calls: _calls)
    }
}

// MARK: Private Functions

private func numberOfMatchingCalls(function: String, arguments: [AnyEquatable], calls: [RecordedCall]) -> Int {
    let matchingFunctions = calls.filter{ $0.function == function }

    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    if arguments.isEmpty {
        return matchingFunctions.count
    }

    return matchingFunctions.reduce(0) { isEqualArgsLists(specifiedArgs: arguments, actualArgs: $1.arguments) ? $0 + 1 : $0 }
}


private func matchingIndexesFor(functionName: String, functionList: [String]) -> [Int] {
    return functionList.enumerated().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
}

private func isOptional(_ value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    
    return mirror.displayStyle == .optional
}

private func description(of calls: [RecordedCall]) -> String {
    guard !calls.isEmpty else {
        return "<>"
    }

    return calls.reduce("") {
        var entry = $1.function

        let arguementListStringRepresentation = $1.arguments.stringRepresentation()
        if !arguementListStringRepresentation.isEmpty {
            entry += " with " + arguementListStringRepresentation
        }

        entry = "<" + entry + ">"

        return $0.isEmpty ? entry : $0 + ", " + entry
    }
}

// MARK: Private Extensions

private extension Array {
    func stringRepresentation() -> String {
        return self.map{ "\($0)" }.joined(separator: ", ")
    }
}
