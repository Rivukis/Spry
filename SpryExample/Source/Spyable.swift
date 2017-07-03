//
//  Spyable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

public protocol Spyable : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var _calls: [RecordedCall] = []
    var _calls: [RecordedCall] { get set }

    // **MUST** call in every method you want to spy
    func recordCall(function: String, arguments: GloballyEquatable...)

    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()

    // Used to determine if a call was made (Only use this is not using the Nimble Matcher)
    func didCall(function: String, withArguments arguments: Array<GloballyEquatable>, countSpecifier: CountSpecifier) -> DidCallResult
}

// MARK: - Helper Objects

public class RecordedCall: CustomStringConvertible {
    let function: String
    let arguments: [GloballyEquatable]

    public var description: String {
        return "RecordedCall(function: <\(function)>, arguments: <\(arguments.map{"<\($0)>"}.joined(separator: ", ")))>"
    }

    init(function: String, arguments: [GloballyEquatable]) {
        self.function = function
        self.arguments = arguments
    }
}

public struct DidCallResult {
    public let success: Bool
    public let recordedCallsDescription: String
}

public enum CountSpecifier {
    case exactly(Int)
    case atLeast(Int)
    case atMost(Int)
}

// MARK - Spyable Extension

public extension Spyable {
    func recordCall(function: String = #function, arguments: GloballyEquatable...) {
        internal_recordCall(function: function, arguments: arguments)
    }

    internal func internal_recordCall(function: String, arguments: [GloballyEquatable]) {
        let call = RecordedCall(function: function, arguments: arguments)
        _calls.append(call)
    }
    
    func clearRecordedLists() {
        _calls = []
    }
    
    func didCall(function: String, withArguments arguments: Array<GloballyEquatable> = [GloballyEquatable](), countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
        case .exactly(let count): success = timesCalled(function, arguments: arguments) == count
        case .atLeast(let count): success = timesCalled(function, arguments: arguments) >= count
        case .atMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }

        let recordedCallsDescription = description(of: _calls)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }
    
    // MARK: - Protocol Extention Helper Functions
    
    private func timesCalled(_ function: String, arguments: Array<GloballyEquatable>) -> Int {
        return numberOfMatchingCalls(function: function, arguments: arguments, calls: _calls)
    }
}

// MARK: Private Helper Functions

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
