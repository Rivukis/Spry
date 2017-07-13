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
