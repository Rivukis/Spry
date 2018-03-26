//
//  Spyable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/1/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 A global NSMapTable to hold onto calls for types conforming to Spyable. This map table has "weak to strong objects" options.
 
 - Important: Do NOT use this object.
 */
private var callsMapTable: NSMapTable<AnyObject, RecordedCallsDictionary> = NSMapTable.weakToStrongObjects()

/**
 A protocol used to spy on an object's function calls. A small amount of boilerplate is requried.
 
 - Important: All the functions specified in this protocol come with default implementation that should NOT be overridden.
 
 - Note: The `Spryable` protocol exists as a convenience to conform to both `Spyable` and `Stubbable` at the same time.
 */
public protocol Spyable: class {

    // MARK: Instance

    /**
     The type that represents function names when spying.

     Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.

     Property signatures are just the property name

     Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead

     - Note: This associatedtype has the exact same name as Stubbable's so that a single type will satisfy both.

     ## Example ##
     ```swift
     enum Function: String, StringRepresentable {
         // property signatures are just the property name
         case myProperty = "myProperty"

         // function signatures are the function name with parameter names listed at the end in "()"
         case giveMeAString = "noParameters()"
         case hereAreTwoParameters = "hereAreTwoParameters(string1:string2:)"
         case paramWithDifferentNames = "paramWithDifferentNames(publicName:)"
         case paramWithNoPublicName = "paramWithNoPublicName(privateName:)"
     }

     func noParameters() -> Bool {
         // ...
     }

     func hereAreTwoParameters(string1: String, string2: String) -> Bool {
         // ...
     }

     func paramWithDifferentNames(publicName privateName: String) -> String {
         // ...
     }

     func paramWithNoPublicName(_ privateName: String) -> String {
         // ...
     }
     ```
     */
    associatedtype Function: StringRepresentable

    /**
     This is where the recorded calls information for instance functions and properties is held. Defaults to using NSMapTable.

     Should ONLY read from this property when debugging.

     - Important: Do not modify this property's value.

     - Note: Override this property if the Spyable object cannot be weakly referenced.

     ## Example Overriding ##
     ```swift
     var _callsDictionary: RecordedCallsDictionary = RecordedCallsDictionary()
     ```
     */
    var _callsDictionary: RecordedCallsDictionary { get }

    /**
     Used to record a function call. Must call in every function for Spyable to work properly.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature to be recorded. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Spyable to work properly.
     */
    func recordCall(functionName: String, arguments: Any?..., file: String, line: Int)

    /**
     Used to determine if a function has been called with the specified arguments and the amount of times specified.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.
     - Important: Only use this function if NOT using the provided `haveReceived()` matcher used in conjunction with [Quick/Nimble](https://github.com/Quick).

     - Parameter function: The `Function` specified.
     - Parameter arguments: The arguments specified. If this value is an empty array, then any parameters passed into the actual function call will result in a success (i.e. passing in `[]` is equivalent to passing in Argument.anything for every expected parameter.)
     - Parameter countSpecifier: Used to specify the amount of times this function needs to be called for a successful result. See `CountSpecifier` for more detials.

     - Returns: A DidCallResult. See `DidCallResult` for more details.
     */
    func didCall(_ function: Function, withArguments arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> DidCallResult

    /**
     Removes all recorded calls.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The spied object will have NO way of knowing about calls made before this function is called. Use with caution.
     */
    func resetCalls()

    // MARK: Static

    /**
     The type that represents function names when spying.

     Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.

     Property signatures are just the property name

     Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead

     - Note: This associatedtype has the exact same name as Stubbable's so that a single type will satisfy both.

     ## Example ##
     ```swift
     enum ClassFunction: String, StringRepresentable {
         // property signatures are just the property name
         case myProperty = "myProperty"

         // function signatures are the function name with parameter names listed at the end in "()"
         case giveMeAString = "noParameters()"
         case hereAreTwoParameters = "hereAreTwoParameters(string1:string2:)"
         case paramWithDifferentNames = "paramWithDifferentNames(publicName:)"
         case paramWithNoPublicName = "paramWithNoPublicName(privateName:)"
     }

     class func noParameters() -> Bool {
         // ...
     }

     class func hereAreTwoParameters(string1: String, string2: String) -> Bool {
         // ...
     }

     class func paramWithDifferentNames(publicName privateName: String) -> String {
         // ...
     }

     class func paramWithNoPublicName(_ privateName: String) -> String {
         // ...
     }
     ```
     */
    associatedtype ClassFunction: StringRepresentable

    /**
     This is where the recorded calls information for class functions and properties is held. Defaults to using NSMapTable.

     Should ONLY read from this property when debugging.

     - Important: Do not modify this property's value.

     - Note: Override this property if the Spyable object cannot be weakly referenced.

     ## Example Overriding ##
     ```swift
     var _callsDictionary: RecordedCallsDictionary = RecordedCallsDictionary()
     ```
     */
    static var _callsDictionary: RecordedCallsDictionary { get }

    /**
     Used to record a function call. Must call in every function for Spyable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature to be recorded. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Spyable to work properly.
     */
    static func recordCall(functionName: String, arguments: Any?..., file: String, line: Int)

    /**
     Used to determine if a function has been called with the specified arguments and the amount of times specified.

     - Important: Do NOT implement function. Use default implementation provided by Spry.
     - Important: Only use this function if NOT using the provided `haveReceived()` matcher used in conjunction with [Quick/Nimble](https://github.com/Quick).

     - Parameter function: The `Function` specified.
     - Parameter arguments: The arguments specified. If this value is an empty array, then any parameters passed into the actual function call will result in a success (i.e. passing in `[]` is equivalent to passing in Argument.anything for every expected parameter.)
     - Parameter countSpecifier: Used to specify the amount of times this function needs to be called for a successful result. See `CountSpecifier` for more detials.

     - Returns: A DidCallResult. See `DidCallResult` for more details.
     */
    static func didCall(_ function: ClassFunction, withArguments arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> DidCallResult

    /**
     Removes all recorded calls.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The spied object will have NO way of knowing about calls made before this function is called. Use with caution.
     */
    static func resetCalls()
}

// MARK - Spyable Extension

public extension Spyable {

    // MARK: Instance

    var _callsDictionary: RecordedCallsDictionary {
        get {
            guard let callsDict = callsMapTable.object(forKey: self) else {
                let callsDict = RecordedCallsDictionary()
                callsMapTable.setObject(callsDict, forKey: self)
                return callsDict
            }

            return callsDict
        }
    }

    func recordCall(functionName: String = #function, arguments: Any?..., file: String = #file, line: Int = #line) {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
    }

    func didCall(_ function: Function, withArguments arguments: [SpryEquatable?] = [], countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
        case .exactly(let count): success = timesCalled(function, arguments: arguments) == count
        case .atLeast(let count): success = timesCalled(function, arguments: arguments) >= count
        case .atMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }

        let recordedCallsDescription = _callsDictionary.friendlyDescription
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }

    func resetCalls() {
        _callsDictionary.clearAllCalls()
    }

    // MARK: Static

    static var _callsDictionary: RecordedCallsDictionary {
        get {
            guard let callsDict = callsMapTable.object(forKey: self) else {
                let callsDict = RecordedCallsDictionary()
                callsMapTable.setObject(callsDict, forKey: self)
                return callsDict
            }

            return callsDict
        }
    }

    static func recordCall(functionName: String = #function, arguments: Any?..., file: String = #file, line: Int = #line) {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
    }

    static func didCall(_ function: ClassFunction, withArguments arguments: [SpryEquatable?] = [], countSpecifier: CountSpecifier = .atLeast(1)) -> DidCallResult {
        let success: Bool
        switch countSpecifier {
        case .exactly(let count): success = timesCalled(function, arguments: arguments) == count
        case .atLeast(let count): success = timesCalled(function, arguments: arguments) >= count
        case .atMost(let count): success = timesCalled(function, arguments: arguments) <= count
        }

        let recordedCallsDescription = _callsDictionary.friendlyDescription
        return DidCallResult(success: success, recordedCallsDescription: recordedCallsDescription)
    }

    static func resetCalls() {
        _callsDictionary.clearAllCalls()
    }

    // MARK: - Internal Functions

    /// This is for `Spryable` to act as a pass-through to record a call.
    internal func internal_recordCall(function: Function, arguments: [Any?]) {
        let call = RecordedCall(functionName: function.rawValue, arguments: arguments)
        _callsDictionary.add(call: call)
    }

    /// This is for `Spryable` to act as a pass-through to record a call.
    internal static func internal_recordCall(function: ClassFunction, arguments: [Any?]) {
        let call = RecordedCall(functionName: function.rawValue, arguments: arguments)
        _callsDictionary.add(call: call)
    }

    // MARK: - Private Functions
    
    private func timesCalled(_ function: Function, arguments: [SpryEquatable?]) -> Int {
        return numberOfMatchingCalls(fakeType: Self.self, functionName: function.rawValue, arguments: arguments, callsDictionary: _callsDictionary)
    }

    private static func timesCalled(_ function: ClassFunction, arguments: [SpryEquatable?]) -> Int {
        return numberOfMatchingCalls(fakeType: Self.self, functionName: function.rawValue, arguments: arguments, callsDictionary: _callsDictionary)
    }
}

// MARK: Private Functions

private func numberOfMatchingCalls<T>(fakeType: T.Type, functionName: String, arguments: [SpryEquatable?], callsDictionary: RecordedCallsDictionary) -> Int {
    let matchingFunctions = callsDictionary.getCalls(for: functionName)

    // if no args passed in then only check if function was called (allows user to not care about args being passed in)
    if arguments.isEmpty {
        return matchingFunctions.count
    }

    return matchingFunctions.reduce(0) {
        return $0 + isEqualArgsLists(fakeType: fakeType, functionName: functionName, specifiedArgs: arguments, actualArgs: $1.arguments).toInt()
    }
}

private func matchingIndexesFor(functionName: String, functionList: [String]) -> [Int] {
    return functionList.enumerated().map { $1 == functionName ? $0 : -1 }.filter { $0 != -1 }
}

private func isOptional(_ value: Any) -> Bool {
    let mirror = Mirror(reflecting: value)
    
    return mirror.displayStyle == .optional
}
