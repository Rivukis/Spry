//
//  Spyable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/2/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 Convenience protocol to conform to and use Spyable and Stubbable protocols with less effort.

 See Spyable and Stubbable or more information.
 */
public protocol Spryable: Spyable, Stubbable {
    associatedtype Function: StringRepresentable

    /**
     For internal use ONLY. Convenience property to help conform to Spyable and Stubbable with less effort.

     See `Spyable`'s `_calls` and `Stubbable`'s `_stubs` or more information.

     - Important: Do not modify this properties value.
     
     - Note: This property satisfies both `Spyable`'s and `Stubbable`'s property requirements. There is no need to implement `_calls` and `_stubs` when conforming to `Spryable`.

     ## Example Conformance ##
     ```swift
     var _spry: (calls: [RecordedCall], stubs: [Stub]) = ([], [])
     ```
     */
    var _spry: (calls: [RecordedCall], stubs: [Stub]) { get set }

    /**
     Convenience function to record a call and return the stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signatgure. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func spryify<T>(_ functionName: String, arguments: Any..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Convenience function to record a call and return the stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func spryify<T>(_ functionName: String, arguments: Any..., fallbackValue: T, file: String, line: Int) -> T
}

public extension Spryable {
    public var _calls: [RecordedCall] {
        get {
            return _spry.calls
        }
        set {
            _spry.calls = newValue
        }
    }

    public var _stubs: [Stub] {
        get {
            return _spry.stubs
        }
        set {
            _spry.stubs = newValue
        }
    }

    func spryify<T>(_ functionName: String = #function, arguments: Any..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function: Function = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(_ functionName: String = #function, arguments: Any..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function: Function = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }
}
