//
//  Stubbable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 8/1/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

import Foundation

// MARK: - Public Helper Objects

/**
 Object return by `stub()` call. Used to specify arguments and return values when stubbing.

 * var description: String - Description of `Stub`.
 * with(arguments:) -> Stub - Use to specify arguments for a given stub.
 * andReturn(value:) - Use to specify the return value for the stubbed function.
 * andDo(closure:) - Use to specify the closure to be executed when the stubbed function is called.
 */

public class Stub: CustomStringConvertible {
    enum StubType {
        case andReturn(Any)
        case andDo(([Any]) -> Any)
    }

    private var stubType: StubType?

    fileprivate let function: String
    fileprivate private(set) var arguments: [AnyEquatable] = []

    fileprivate init(function: String) {
        self.function = function
    }

    // MARK: - Public

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        let argumentsString = arguments.map{"<\($0)>"}.joined(separator: ", ")
        let returnString = stubType == nil ? "nil" : "\(stubType!)"
        return "Stub(function: <\(function)>, args: <\(argumentsString)>, returnValue: <\(returnString)>)"
    }

    /**
     Used to specify arguments when stubbing.
     
     - Note: If no arguments are specified then any arguments may be passed in and the stubbed value will still be returned.
     
     - Parameter arguments: The specified arguments needed for the stub to succeed.
     
     - Returns: A stub object used to add additional `with()` or to add `andReturn()` or `andDo()`.
     */
    public func with(_ arguments: AnyEquatable...) -> Stub {
        self.arguments += arguments
        return self
    }

    /**
     Used to specify the return value for the stubbed function.
     
     - Important: This allows any object to be passed in but the stub will ONLY work if the correct type is passed in.
     
     - Note: ONLY the last `andReturn()` or `andDo()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).

     - Parameter value: The value to be returned by the stubbed function.
     */
    public func andReturn(_ value: Any) {
        stubType = .andReturn(value)
    }

    /**
     Used to specify a closure to be executed in place of the stubbed function.
     
     - Note: ONLY the last `andReturn()` or `andDo()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).

     - Parameter closure: The closure to be executed. The array of parameters that will be passed in correspond to the parameters being passed into the stubbed function. The return value must match the stubbed function's return type and will be the return value of the stubbed function.
     */
    public func andDo(_ closure: @escaping ([Any]) -> Any) {
        stubType = .andDo(closure)
    }

    // MARK: - Fileprivate

    fileprivate func returnValue(for args: [Any]) -> Any {
        guard let stubType = stubType else {
            fatalError("Must add `andReturn` or `andDo` to properly stub an object")
        }

        switch stubType {
        case .andReturn(let value):
            return value
        case .andDo(let closure):
            return closure(args)
        }
    }
}

/**
 A protocol used to stub an object's functions. A small amount of boilerplate is requried.

 - Important: All the functions specified in this protocol come with default implementation that should NOT be overridden.

 - Note: The `Spryable` protocol exists as a convenience when conforming to both `Spyable` and `Stubbable`.

 * var _stubs: [Stub] - Used internally to keep track of stubs.
 * stub(function: String) -> Stub - Used to stub the specified function. See `Stub` for specifying arguments and the stubbed return value.
 * stubbedValue<T>(function:arguments:asType:) -> T - Used to return the stubbed value.
 * stubbedValue<T>(function:arguments:fallbackValue:) -> T - Used to return the stubbed value or the fallback value if no stub is found.
 */
public protocol Stubbable: class {
    /**
     For internal use ONLY.

     Should ONLY read from this property when debugging.

     - Important: Do not modify this properties value.

     ## Example Conformance ##
     ```swift
     var _calls: [RecordedCall] = []
     ```
     */
    var _stubs: [Stub] { get set }

    /**
     Used to stub a function. All stubs must proved either `andReturn()` or `andDo()` to work properly. May also specify arguments using `with()`.
     
     See `Stub` for specifying arguments and return value.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature to be stubbed. Defaults to #function.
     */
    func stub(_ function: String) -> Stub

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` in every function for Stubbable to work properly.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func stubbedValue<T>(function: String, arguments: Any..., asType _: T.Type) -> T

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` in every function for Stubbable to work properly.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func stubbedValue<T>(function: String, arguments: Any..., fallbackValue: T) -> T
}

internal enum Fallback<T> {
    case noFallback
    case fallback(T)
}

// MARK - Stubbable Extension

public extension Stubbable {
    func stub(_ function: String) -> Stub {
        let stub = Stub(function: function)
        _stubs.append(stub)

        return stub
    }

    // TODO: rename to stubbedValue()
    func stubbedValue<T>(function: String = #function, arguments: Any..., asType _: T.Type = T.self) -> T {
        return internal_stubbedValue(function: function, arguments: arguments, fallback: .noFallback)
    }

    func stubbedValue<T>(function: String = #function, arguments: Any..., fallbackValue: T) -> T {
        return internal_stubbedValue(function: function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    // MARK: - Internal Helper Functions

    internal func internal_stubbedValue<T>(function: String, arguments: [Any], fallback: Fallback<T>) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        if stubsForFunctionName.isEmpty {
            return fatalErrorOrReturnFallback(fallback: fallback, stubs: _stubs, function: function, arguments: arguments)
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(specifiedArgs: stub.arguments, actualArgs: arguments), let value = stub.returnValue(for: arguments) as? T {
                return value
            }
        }

        for stub in stubsWithoutArgs {
            if let value = stub.returnValue as? T {
                return value
            }

            if let value = stub.returnValue(for: arguments) as? T {
                return value
            }
        }

        return fatalErrorOrReturnFallback(fallback: fallback, stubs: _stubs, function: function, arguments: arguments)
    }

    // MARK: - Private Helper Functions

    private func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, stubs: [Stub], function: String, arguments: [Any]) -> T {
        switch fallback {
        case .noFallback:
            let argumentsDescription = arguments.map{"<\($0)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(type(of: self)).\(function)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(T.self)>. Current stubs: <\(stubs)>.")
        case .fallback(let value):
            return value
        }
    }
}

// MARK: Private Extensions

extension Array {
    /**
     Splits the array into two separate arrays.

     - Parameter closure: The closure to determine which array each element will be put into. Return `true` to put item in first array and `false` to put it into the second array.
     */
    func bisect(_ closure: (Element) -> Bool) -> ([Element], [Element]) {
        var arrays = ([Element](), [Element]())
        self.forEach { closure($0) ? arrays.0.append($0) : arrays.1.append($0) }

        return arrays
    }
}
