//
//  CallRecorder.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

// MARK: Helper Objects

public struct DidCallResult {
    public let success: Bool
    public let recordedCallsDescription: String
}

public enum CountSpecifier {
    case Exactly(Int)
    case AtLeast(Int)
    case AtMost(Int)
}

// MARK: CallRecorder Protocol

public protocol CallRecorder : class {
    // For Interal Use ONLY -> Implement as empty properties when conforming to protocol
    // Implementation Example:
    // var called = (functionList: [String](), argumentsList: [[GloballyEquatable]]())
    var _calls: (functionList: [String], argumentsList: [[GloballyEquatable]]) {get set}
    
    // **MUST** call in every method you want to spy
    func recordCall(function: String, arguments: GloballyEquatable...)
    
    // Used if you want to reset the called function/arguments lists
    func clearRecordedLists()

    // Used to determine if a call was made (Only use this is not using the Nimble Matcher)
    func didCall(function: String, withArguments arguments: Array<GloballyEquatable>, countSpecifier: CountSpecifier) -> DidCallResult
}

public extension CallRecorder {
    func recordCall(function: String = #function, arguments: GloballyEquatable...) {
        _calls.functionList.append(function)
        _calls.argumentsList.append(arguments)
    }
    
    func clearRecordedLists() {
        _calls.functionList = Array<String>()
        _calls.argumentsList = Array<Array<GloballyEquatable>>()
    }
    
    func didCall(function: String, withArguments arguments: Array<GloballyEquatable> = [GloballyEquatable](), countSpecifier: CountSpecifier = .AtLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
            case .Exactly(let count): success = timesCalled(function, arguments: arguments) == count
            case .AtLeast(let count): success = timesCalled(function, arguments: arguments) >= count
            case .AtMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }
        
        let recordedCallsDescription = descriptionOfCalls(functionList: _calls.functionList, argumentsList: _calls.argumentsList)
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }
    
    // MARK: Protocol Extention Helper Functions
    
    private func timesCalled(_ function: String, arguments: Array<GloballyEquatable>) -> Int {
        return numberOfMatchingCalls(function: function, functions: _calls.functionList, argsList: arguments, argsLists: _calls.argumentsList)
    }
}

// MARK: Private Helper Functions

private func numberOfMatchingCalls(function: String, functions: Array<String>, argsList: Array<GloballyEquatable>, argsLists: Array<Array<GloballyEquatable>>) -> Int {
    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    guard argsList.count != 0 else {
        return functions.reduce(0) { $1 == function ? $0 + 1 : $0 }
    }
    
    let potentialMatchIndexes = matchingIndexesFor(functionName: function, functionList: functions)
    var correctCallsCount = 0
    
    for index in potentialMatchIndexes {
        let recordedArgsList = argsLists[index]
        if isEqualArgsLists(specifiedArgs: argsList, actualArgs: recordedArgsList) {
            correctCallsCount += 1
        }
    }
    
    return correctCallsCount
}

private func matchingIndexesFor(functionName: String, functionList: Array<String>) -> [Int] {
    return functionList.enumerated().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
}

private func isOptional(_ value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    
    return mirror.displayStyle == .optional
}

private func descriptionOfCalls(functionList: Array<String>, argumentsList: Array<Array<GloballyEquatable>>) -> String {
    if functionList.isEmpty {
        return "<>"
    }
    
    return zip(functionList, argumentsList).reduce("") { (concatenatedString, element: (function: String, argumentList: Array<GloballyEquatable>)) -> String in
        var entry = element.function
        
        let parameterListStringRepresentation = element.argumentList.stringRepresentation()
        if !parameterListStringRepresentation.isEmpty {
            entry += " with " + parameterListStringRepresentation
        }
        entry = "<" + entry + ">"
        
        return concatenatedString.isEmpty ? entry : concatenatedString + ", " + entry
    }
}

// MARK: Private Extensions

private extension Array {
    func stringRepresentation() -> String {
        return self.map{ "\($0)" }.joined(separator: ", ")
    }
}
