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
private var stubsMapTable: NSMapTable<AnyObject, StubsDictionary> = NSMapTable.weakToStrongObjects()

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
     var _stubsDictionary: StubsDictionary = StubsDictionary()
     ```
     */
    var _stubsDictionary: StubsDictionary { get }

    /**
     Used to stub a function. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.

     - Note: If the same function is stubbed with the same argument specifications, then this function will fatal error. Stubbing the same thing again is usually a code smell. If this necessary then use `.stubAgain`.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The `Function` to be stubbed.
     - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
     */
    func stub(_ function: Function) -> Stub

    /**
     Used to stub a function *AGAIN*. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.

     - Note: Stubbing the same thing again is usually a code smell. If this is necessary, then use this function otherwise use `.stub()`.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The `Function` to be stubbed.
     - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
     */
    func stubAgain(_ function: Function) -> Stub

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func stubbedValue<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution. Defaults to .noFallback
     */
    func stubbedValue<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /**
     Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution. Defaults to .noFallback
     */
    func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /**
     Removes all stubs.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The stubbed object will have NO way of knowing about stubs made before this function is called. Use with caution.
     */
    func resetStubs()

    // MARK: - Static

    /**
     The type that represents class function and property names when stubbing.

     Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.

     Property signatures are just the property name

     Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead

     - Note: This associatedtype has the exact same name as Spyable's so that a single type will satisfy both.

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
     This is where the stubbed information for class functions and properties is held. Defaults to using NSMapTable.

     Should ONLY read from this property when debugging.

     - Important: Do not modify this property's value.

     - Note: Override this property if the Stubbable object cannot be weakly referenced.

     ## Example Overriding ##
     ```swift
     var _stubsDictionary: StubsDictionary = StubsDictionary()
     ```
     */
    static var _stubsDictionary: StubsDictionary { get }

    /**
     Used to stub a function. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The `ClassFunction` to be stubbed.
     - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
     */
    static func stub(_ function: ClassFunction) -> Stub

    /**
     Used to stub a function *AGAIN*. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.

     - Note: Stubbing the same thing again is usually a code smell. If this is necessary, then use this function otherwise use `.stub()`.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The `Function` to be stubbed.
     - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
     */
    static func stubAgain(_ function: ClassFunction) -> Stub

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    static func stubbedValue<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /**
     Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    static func stubbedValue<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /**
     Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
     */
    static func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /**
     Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Parameter function: The function signature used to find a stub. Defaults to #function.
     - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
     - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
     */
    static func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /**
     Removes all stubs.

     - Important: Do NOT implement function. Use default implementation provided by Spry.

     - Important: The stubbed object will have NO way of knowing about stubs made before this function is called. Use with caution.
     */
    static func resetStubs()
}

public extension Stubbable {

    // MARK: - Instance

    var _stubsDictionary: StubsDictionary {
        get {
            guard let stubsDict = stubsMapTable.object(forKey: self) else {
                let stubDict = StubsDictionary()
                stubsMapTable.setObject(stubDict, forKey: self)
                return stubDict
            }

            return stubsDict
        }
    }

    func stub(_ function: Function) -> Stub {
        let stub = Stub(functionName: function.rawValue, stubCompleteHandler: { [weak self] stub in
            guard let welf = self else {
                return
            }

            handleDuplicates(stubsDictionary: welf._stubsDictionary, stub: stub, again: false)
        })
        _stubsDictionary.add(stub: stub)

        return stub
    }

    func stubAgain(_ function: Function) -> Stub {
        let stub = Stub(functionName: function.rawValue, stubCompleteHandler: { [weak self] stub in
            guard let welf = self else {
                return
            }

            handleDuplicates(stubsDictionary: welf._stubsDictionary, stub: stub, again: true)
        })
        _stubsDictionary.add(stub: stub)

        return stub
    }

    func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingInstanceFunction(stubbable: self, function: function)
        }
    }

    func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        let function = Function(functionName: functionName, type: Self.self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    func resetStubs() {
        _stubsDictionary.clearAllStubs()
    }

    // MARK: - Static

    static var _stubsDictionary: StubsDictionary {
        get {
            guard let stubDict = stubsMapTable.object(forKey: self) else {
                let stubDict = StubsDictionary()
                stubsMapTable.setObject(stubDict, forKey: self)
                return stubDict
            }

            return stubDict
        }
    }

    static func stub(_ function: ClassFunction) -> Stub {
        let stub = Stub(functionName: function.rawValue, stubCompleteHandler: { stub in
            handleDuplicates(stubsDictionary: _stubsDictionary, stub: stub, again: false)
        })
        _stubsDictionary.add(stub: stub)

        return stub
    }

    static func stubAgain(_ function: ClassFunction) -> Stub {
        let stub = Stub(functionName: function.rawValue, stubCompleteHandler: { stub in
            handleDuplicates(stubsDictionary: _stubsDictionary, stub: stub, again: true)
        })
        _stubsDictionary.add(stub: stub)

        return stub
    }

    static func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func stubbedValue<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        do {
            return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
        } catch {
            Constant.FatalError.andThrowOnNonThrowingClassFunction(stubbable: self, function: function)
        }
    }

    static func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., asType _: T.Type = T.self, file: String = #file, line: Int = #line) throws -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .noFallback)
    }

    static func stubbedValueThrows<T>(_ functionName: String = #function, arguments: Any?..., fallbackValue: T, file: String = #file, line: Int = #line) throws -> T {
        let function = ClassFunction(functionName: functionName, type: self, file: file, line: line)
        return try internal_stubbedValue(function, arguments: arguments, fallback: .fallback(fallbackValue))
    }

    static func resetStubs() {
        _stubsDictionary.clearAllStubs()
    }

    // MARK: - Internal Helper Functions

    internal func internal_stubbedValue<T>(_ function: Function, arguments: [Any?], fallback: Fallback<T>) throws -> T {
        let stubsForFunctionName = _stubsDictionary.getStubs(for: function.rawValue)

        if stubsForFunctionName.isEmpty {
            return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(fakeType: Self.self, functionName: function.rawValue, specifiedArgs: stub.arguments, actualArgs: arguments) {
                let rawValue = try stub.returnValue(for: arguments)

                if isNil(rawValue) {
                    // nils won't cast to T even when T is Optional unless cast to Any first
                    if let castedValue = rawValue as Any as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                } else {
                    // values won't cast to T when T is a protocol if values is cast to Any first
                    if let castedValue = rawValue as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                }
            }
        }

        for stub in stubsWithoutArgs {
            let rawValue = try stub.returnValue(for: arguments)

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

        return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
    }

    internal static func internal_stubbedValue<T>(_ function: ClassFunction, arguments: [Any?], fallback: Fallback<T>) throws -> T {
        let stubsForFunctionName = _stubsDictionary.getStubs(for: function.rawValue)

        if stubsForFunctionName.isEmpty {
            return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(fakeType: Self.self, functionName: function.rawValue, specifiedArgs: stub.arguments, actualArgs: arguments) {
                let rawValue = try stub.returnValue(for: arguments)

                if isNil(rawValue) {
                    // nils won't cast to T even when T is Optional unless cast to Any first
                    if let castedValue = rawValue as Any as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                } else {
                    // values won't cast to T when T is a protocol if values is cast to Any first
                    if let castedValue = rawValue as? T {
                        captureArguments(stub: stub, actualArgs: arguments)
                        return castedValue
                    }
                }
            }
        }

        for stub in stubsWithoutArgs {
            let rawValue = try stub.returnValue(for: arguments)

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

        return fatalErrorOrReturnFallback(fallback: fallback, function: function, arguments: arguments)
    }

    // MARK: - Private Helper Functions

    private func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, function: Function, arguments: [Any?]) -> T {
        switch fallback {
        case .noFallback:
            Constant.FatalError.noReturnValueFoundForInstanceFunction(stubbable: self, function: function, arguments: arguments, returnType: T.self)
        case .fallback(let value):
            return value
        }
    }

    private static func fatalErrorOrReturnFallback<T>(fallback: Fallback<T>, function: ClassFunction, arguments: [Any?]) -> T {
        switch fallback {
        case .noFallback:
            Constant.FatalError.noReturnValueFoundForClassFunction(stubbableType: self, function: function, arguments: arguments, returnType: T.self)
        case .fallback(let value):
            return value
        }
    }
}

private func handleDuplicates(stubsDictionary: StubsDictionary, stub: Stub, again: Bool) {
    let duplicates = stubsDictionary.completedDuplicates(of: stub)

    if duplicates.isEmpty {
        return
    }

    if again {
        stubsDictionary.remove(stubs: duplicates, forFunctionName: stub.functionName)
    }
    else {
        Constant.FatalError.stubbingSameFunctionWithSameArguments(stub: stub)
    }
}

private func captureArguments(stub: Stub, actualArgs: [Any?]) {
    zip(stub.arguments, actualArgs).forEach { (specifiedArg, actual) in
        if let specifiedArg = specifiedArg as? ArgumentCaptor {
            specifiedArg.capture(actual)
        }
    }
}
