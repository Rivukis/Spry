//
//  Spyable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/2/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

// MARK: - Public Helper Objects

/**
 Used internally. Should never need to use or know about this type.

 * function: String - The function signature of a recorded call. Defaults to `#function`.
 * arguments: [Any] - The arguments passed in when the function was recorded.
 */
public class SpryProperties: CustomStringConvertible {
    var _calls: [RecordedCall] = []
    var _stubs: [Stub] = []

    public init() {}

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        return "SpryableProperties(_calls: <\(_calls)>, _stubs: <\(_stubs)))>"
    }
}

/**
 Convenience protocol to conform to and use Spyable and Stubbable protocols with less effort.

 See Spyable and Stubbable or more information.
 */
public protocol Spryable: Spyable, Stubbable {
    /**
     Convenience property to help conform to Spyable and Stubbable with less effort.

     See `Spyable`'s `_calls` and `Stubbable`'s `_stubs` for more information.

     - Important: Do not modify this properties value.
     
     - Note: This property satisfies both `Spyable`'s and `Stubbable`'s property requirements. There is no need to implement `_calls` and `_stubs` when conforming to `Spryable`.

     ## Example Conformance ##
     ```swift
     var _spry: SpryProperties = SpryProperties()
     ```
     */
    var _spry: SpryProperties { get set }

    /**
     Convenience function to record a call and return the stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signatgure. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func spryify<T>(function: String, arguments: Any..., asType _: T.Type) -> T

    /**
     Convenience function to record a call and return the stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func spryify<T>(function: String, arguments: Any..., fallbackValue: T) -> T
}

public extension Spryable {
    public var _calls: [RecordedCall] {
        get {
            return _spry._calls
        }
        set {
            _spry._calls = newValue
        }
    }

    public var _stubs: [Stub] {
        get {
            return _spry._stubs
        }
        set {
            _spry._stubs = newValue
        }
    }

    func spryify<T>(function: String = #function, arguments: Any..., asType _: T.Type = T.self) -> T {
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function: function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(function: String = #function, arguments: Any..., fallbackValue: T) -> T {
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function: function, arguments: arguments, fallback: .fallback(fallbackValue))
    }
}
