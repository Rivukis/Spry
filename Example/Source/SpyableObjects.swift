//
//  RecordedCall.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/16/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 Used internally. Should never need to use or know about this type.

 * function: String - The function signature of a recorded call. Defaults to `#function`.
 * arguments: [Any] - The arguments passed in when the function was recorded.
 */
public class RecordedCall: CustomStringConvertible {
    let functionName: String
    let arguments: [Any?]
    var chronologicalIndex = -1

    internal init(functionName: String, arguments: [Any?]) {
        self.functionName = functionName
        self.arguments = arguments
    }

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        let argumentsString = arguments.map{"<\($0 as Any)>"}.joined(separator: ", ")
        return "RecordedCall(function: <\(functionName)>, arguments: <\(argumentsString)>)"
    }

    /// A beautified description. Used for logging.
    public var friendlyDescription: String {
        let functionStringRepresentation = "<" + functionName + ">"
        let arguementListStringRepresentation = arguments
            .map { "<\($0.stringRepresentation())>" }
            .joined(separator: ", ")

        if !arguementListStringRepresentation.isEmpty {
            return functionStringRepresentation + " with " + arguementListStringRepresentation
        }

        return functionStringRepresentation
    }
}

/**
 This exists because a dictionary is needed as a class. Instances of this type are put into an NSMapTable.
 */
public class RecordedCallsDictionary: CustomStringConvertible {
    private var callsDict: [String: [RecordedCall]] = [:]
    private var recordedCount = 0

    func add(call: RecordedCall) {
        var calls = callsDict[call.functionName] ?? []

        call.chronologicalIndex = recordedCount
        recordedCount += 1
        calls.insert(call, at: 0)
        callsDict[call.functionName] = calls
    }

    func getCalls(for functionName: String) -> [RecordedCall] {
        return callsDict[functionName] ?? []
    }

    func clearAllCalls() {
        recordedCount = 0
        callsDict = [:]
    }

    public var description: String {
        return String(describing: callsDict)
    }

    public var friendlyDescription: String {
        guard !callsDict.isEmpty else {
            return "<>"
        }

        let callsInChronologicalOrder = callsDict
            .values
            .flatMap { $0 }
            .sorted { $0.chronologicalIndex < $1.chronologicalIndex}

        return callsInChronologicalOrder
            .map { $0.friendlyDescription }
            .joined(separator: "; ")
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
