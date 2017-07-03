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

    /**
     A beautified description. Used for debugging purposes.
     */
    public var description: String {
        return "RecordedCall(function: <\(function)>, arguments: <\(arguments.map{"<\($0)>"}.joined(separator: ", ")))>"
    }

    init(function: String, arguments: [Any]) {
        self.function = function
        self.arguments = arguments
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
 A protocol used to spy on objects. A small amount of boilerplate is requried.
 
 All the functions specified in this protocol come with default implementation that should NOT be overridden.
 
 * var _calls: [RecordedCall] - Used internally to keep track of a recorded calls.
 * recoredCall(function: String, arguments: Any...) - Used to record a call.
 * clearRecordedLists() - Used to clear out all recorded calls.
 * didCall(function: String, withArguments arguments: [GloballyEquatable], countSpecifier: CountSpecifier) -> DidCallResult - Used to find out if a call was made.
 */
public protocol Spyable: class {
    /**
     For internal use ONLY.
     
     Should ONLY read from this property when debugging.
     
     - Important: Do not modify this properties value.
     
     ## Example Conformance ##
     ```swift
     var _calls: [RecordedCall] = []
     ```
     */
    var _calls: [RecordedCall] { get set }

    /**
     Used to record a call. Must call in every function for Spyable to work properly.
     
     - Important: Do NOT implement function. Use default implement provided by Spry.

     - Parameter function: The function to be recorded. Defaults to `#function`.
     - Parameter arguments: The arguments to be recorded.
     */
    func recordCall(function: String, arguments: Any...)

    // Used if you want to reset the called function/arguments lists

    /**
     Used to clear out all recorded function calls.
     
     - Important: The spied object will have NO way of knowing about calls made before this function is called. Use with caution.
     */
    func clearRecordedLists()

    // Used to determine if a call was made (Only use this is not using the Nimble Matcher)

    /**
     Used to determine if a function has been called with the specified arguments and with the amount of times specified.
     
     - Parameter function: The function signature as a `String`.
     - Parameter arguments: The arguments specified. If this value is an empty array, then any parameters passed into the actual function call will result in a success (i.e. passing in `[]` is equivalent to passing in Argument.anything for every expected parameter.)
     - Parameter countSpecifier: Used to specify the amount of times this function needs to be called for a successful result. See `CountSpecifier` for more detials.
     
     - Returns: A DidCallResult. See `DidCallResult` for more details.
     */
    func didCall(function: String, withArguments arguments: [GloballyEquatable], countSpecifier: CountSpecifier) -> DidCallResult
}

// MARK - Spyable Extension

public extension Spyable {
    func recordCall(function: String = #function, arguments: Any...) {
        internal_recordCall(function: function, arguments: arguments)
    }

    func clearRecordedLists() {
        _calls = []
    }
    
    func didCall(function: String, withArguments arguments: [GloballyEquatable] = [], countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
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

    internal func internal_recordCall(function: String, arguments: [Any]) {
        let call = RecordedCall(function: function, arguments: arguments)
        _calls.append(call)
    }

    // MARK: - Private Functions
    
    private func timesCalled(_ function: String, arguments: [GloballyEquatable]) -> Int {
        return numberOfMatchingCalls(function: function, arguments: arguments, calls: _calls)
    }
}

// MARK: Private Functions

private func numberOfMatchingCalls(function: String, arguments: [GloballyEquatable], calls: [RecordedCall]) -> Int {
    let matchingFunctions = calls.filter{ $0.function == function }

    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    if arguments.isEmpty {
        return matchingFunctions.count
    }

    return matchingFunctions.reduce(0) { isEqualArgsLists(specifiedArgs: arguments, actualArgs: $1.arguments) ? $0 + 1 : $0 }
}


private func matchingIndexesFor(functionName: String, functionList: Array<String>) -> [Int] {
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
