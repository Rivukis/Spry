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
    let function: String
    let arguments: [Any?]

    internal init(function: String, arguments: [Any?]) {
        self.function = function
        self.arguments = arguments
    }

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        return "RecordedCall(function: <\(function)>, arguments: <\(arguments.map{"<\($0 as Any)>"}.joined(separator: ", ")))>"
    }
}

/**
 This exists because an array is needed as a class. Instances of this type are put into an NSMapTable.
 */
internal class RecordedCallArray {
    var calls: [RecordedCall] = []
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
