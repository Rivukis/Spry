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
    /**
     The type that represents function names when spying.

     Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.

     Property signatures are just the property name

     Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead

     - Note: This associatedtype has the exact same name as Stubbable's and Spyable's so that a single type will satisfy both.

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
     Convenience function to record a call and return the stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signatgure. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func spryify<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Convenience function to record a call and return the stubbed value.

     See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature. Defaults to #function.
     - Parameter arguments: The function arguments being passed in.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func spryify<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Removes all recorded and stubbed functions/properties.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The spryified object will have NO way of knowing about calls or stubs made before this function is called. Use with caution.
     */
    func resetCallsAndStubs()
}

public extension Spryable {
    func spryify<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function: Function = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function: Function = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func resetCallsAndStubs() {
        resetCalls()
        resetStubs()
    }
}
