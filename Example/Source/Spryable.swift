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

    // MARK: Instance

    /**
     Convenience function to record a call and return a stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func spryify<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Convenience function to record a call and return a stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func spryify<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Convenience function to record a call and return a stubbed value from a throwable function.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValueThrows()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func spryifyThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /**
     Convenience function to record a call and return a stubbed value from a throwable function.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func spryifyThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /**
     Removes all recorded calls and stubs.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The spryified object will have NO way of knowing about calls or stubs made before this function is called. Use with caution.
     */
    func resetCallsAndStubs()

    // MARK: - Static

    /**
     Convenience function to record a call and return a stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    static func spryify<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Convenience function to record a call and return a stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    static func spryify<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Convenience function to record a call and return a stubbed value from a throwable function.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    static func spryifyThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /**
     Convenience function to record a call and return a stubbed value from a throwable function.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    static func spryifyThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /**
     Removes all recorded calls and stubs.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The spryified object will have NO way of knowing about calls or stubs made before this function is called. Use with caution.
     */
    static func resetCallsAndStubs()
}

public extension Spryable {

    // MARK: - Instance

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }

    // MARK: - Static

    static func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func spryify<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    static func spryifyThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    static func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }
}
