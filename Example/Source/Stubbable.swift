//
//  Stubbable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 8/1/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 A global NSMapTable to hold onto stubs for types conforming to Stubbable. This map table has "weak to strong objects" options.

 - Important: Do NOT use this object.
 */
private var stubsMapTable: NSMapTable<AnyObject, StubArray> = NSMapTable.weakToStrongObjects()

/**
 A protocol used to stub an object's functions. A small amount of boilerplate is requried.

 - Important: All the functions specified in this protocol come with default implementation that should NOT be overridden.

 - Note: The `Spryable` protocol exists as a convenience to conform to both `Spyable` and `Stubbable` at the same time.
 */
public protocol Stubbable: class {

    // MARK: - Instance

    /**
     The type that represents function and property names when stubbing.
     
     Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.
     
     Property signatures are just the property name
     
     Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead
     
     - Note: This associatedtype has the exact same name as Spyable's so that a single type will satisfy both.
     
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
     This is where the stubbed information for instance functions and properties is held. Defaults to using NSMapTable.

     Should ONLY read from this property when debugging.

     - Important: Do not modify this property's value.

     - Note: Override this property if the Stubbable object cannot be weakly referenced.

     ## Example Overriding ##
     ```swift
     var _stubs: [Stub] = []
     ```
     */
    var _stubs: [Stub] { get set }

    /**
     Used to stub a function. All stubs must be provided either `andReturn()` or `andDo()` to work properly. May also specify arguments using `with()`.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The `Function` to be stubbed.
     - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
     */
    func stub(_ function: Function) -> Stub

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` in every function for Stubbable to work properly.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func stubbedValue<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` in every function for Stubbable to work properly.
     
     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    func stubbedValue<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Removes all stubs.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The stubbed object will have NO way of knowing about stubs made before this function is called. Use with caution.
     */
    func resetStubs()

    // MARK: - Static

    /**
     The type that represents static function and property names when stubbing.

     Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.

     Property signatures are just the property name

     Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead

     - Note: This associatedtype has the exact same name as Spyable's so that a single type will satisfy both.

     ## Example ##
     ```swift
     enum StaticFunction: String, StringRepresentable {
         // property signatures are just the property name
         case myProperty = "myProperty"

         // function signatures are the function name with parameter names listed at the end in "()"
         case giveMeAString = "noParameters()"
         case hereAreTwoParameters = "hereAreTwoParameters(string1:string2:)"
         case paramWithDifferentNames = "paramWithDifferentNames(publicName:)"
         case paramWithNoPublicName = "paramWithNoPublicName(privateName:)"
     }

     static func noParameters() -> Bool {
         // ...
     }

     static func hereAreTwoParameters(string1: String, string2: String) -> Bool {
         // ...
     }

     static func paramWithDifferentNames(publicName privateName: String) -> String {
         // ...
     }

     static func paramWithNoPublicName(_ privateName: String) -> String {
         // ...
     }
     ```
     */
    associatedtype StaticFunction: StringRepresentable

    /**
     This is where the stubbed information for static functions and properties is held. Defaults to using NSMapTable.

     Should ONLY read from this property when debugging.

     - Important: Do not modify this property's value.

     - Note: Override this property if the Stubbable object cannot be weakly referenced.

     ## Example Overriding ##
     ```swift
     var _stubs: [Stub] = []
     ```
     */
    static var _stubs: [Stub] { get set }

    /**
     Used to stub a function. All stubs must be provided either `andReturn()` or `andDo()` to work properly. May also specify arguments using `with()`.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The `StaticFunction` to be stubbed.
     - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
     */
    static func stub(_ function: StaticFunction) -> Stub

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    static func stubbedValue<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    static func stubbedValue<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Removes all stubs.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The stubbed object will have NO way of knowing about stubs made before this function is called. Use with caution.
     */
    static func resetStubs()
}

public extension Stubbable {

    // MARK: - Instance

    var _stubs: [Stub] {
        set {
            let stubArray = stubsMapTable.object(forKey: self) ?? StubArray()
            stubArray.stubs = newValue
            stubsMapTable.setObject(stubArray, forKey: self)
        }
        get {
            let stubArray = stubsMapTable.object(forKey: self) ?? StubArray()
            stubsMapTable.setObject(stubArray, forKey: self)
            return stubArray.stubs
        }
    }

    func stub(_ function: Function) -> Stub {
        let stub = Stub(functionName: function.rawValue)
        _stubs.append(stub)

        return stub
    }

    func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function: Function = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        return internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function: Function = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        return internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func resetStubs() {
        _stubs = []
    }

    // MARK: - Static

    static var _stubs: [Stub] {
        set {
            let stubArray = stubsMapTable.object(forKey: self) ?? StubArray()
            stubArray.stubs = newValue
            stubsMapTable.setObject(stubArray, forKey: self)
        }
        get {
            let stubArray = stubsMapTable.object(forKey: self) ?? StubArray()
            stubsMapTable.setObject(stubArray, forKey: self)
            return stubArray.stubs
        }
    }

    static func stub(_ function: StaticFunction) -> Stub {
        let stub = Stub(functionName: function.rawValue)
        _stubs.append(stub)

        return stub
    }

    static func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function: StaticFunction = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        return internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    static func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function: StaticFunction = fatalErrorOrFunction(functionName: functionName, file: file, line: line)
        return internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    static func resetStubs() {
        _stubs = []
    }

    // MARK: - Internal Helper Functions

    internal func internal_stubbedValue<T>(_ function: Function, arguments: [Any?], fallback: Fallback<T>) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.functionName == function.rawValue }

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
            let rawValue = stub.returnValue(for: arguments)

            if isNil(rawValue) {
                // nils won't cast to T even when T is Optional unless cast to Any first
                if let castedValue = rawValue as Any as? T {
                    return castedValue
                }
            } else {
                // values won't cast to T when T is a protocol if values is cast to Any first
                if let castedValue = rawValue as? T {
                    return castedValue
                }
            }
        }

        return fatalErrorOrReturnFallback(fallback: fallback, stubs: _stubs, function: function, arguments: arguments)
    }

    internal static func internal_stubbedValue<T>(_ function: StaticFunction, arguments: [Any?], fallback: Fallback<T>) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.functionName == function.rawValue }

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
            let rawValue = stub.returnValue(for: arguments)

            if isNil(rawValue) {
                // nils won't cast to T even when T is Optional unless cast to Any first
                if let castedValue = rawValue as Any as? T {
                    return castedValue
                }
            } else {
                // values won't cast to T when T is a protocol if values is cast to Any first
                if let castedValue = rawValue as? T {
                    return castedValue
                }
            }
        }

        return fatalErrorOrReturnFallback(fallback: fallback, stubs: _stubs, function: function, arguments: arguments)
    }

    // MARK: - Private Helper Functions

    private func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, stubs: [Stub], function: Function, arguments: [Any?]) -> T {
        switch fallback {
        case .noFallback:
            let argumentsDescription = arguments.map{"<\($0 as Any)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(type(of: self)).\(function.rawValue)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(T.self)>. Current stubs: <\(stubs)>.")
        case .fallback(let value):
            return value
        }
    }

    private static func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, stubs: [Stub], function: StaticFunction, arguments: [Any?]) -> T {
        switch fallback {
        case .noFallback:
            let argumentsDescription = arguments.map{"<\($0 as Any)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(type(of: self)).\(function.rawValue)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(T.self)>. Current stubs: <\(stubs)>.")
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
