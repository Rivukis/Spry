//
//  Stubable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

// MARK: Private Extensions

public protocol Stubable: class {
    var _stubs: [Stub] { get set }

    func stub(_ function: String) -> Stub

    func returnValue<T>(function: String, arguments: GloballyEquatable...) -> T
    func returnValue<T>(asType _: T.Type, function: String, arguments: GloballyEquatable...) -> T
    func returnValue<T>(withFallbackValue fallbackValue: T, function: String, arguments: GloballyEquatable...) -> T
}

// MARK: - Helper Objects

public class Stub: CustomStringConvertible {
    let function: String
    private(set) var arguments: [GloballyEquatable] = []
    private(set) var returnValue: Any? = nil

    public var description: String {
        return "Stub(function: <\(function)>, args: <\(arguments.map{"<\($0)>"}.joined(separator: ", "))>, returnValue: <\(returnValue ?? "nil")>)"
    }

    init(function: String) {
        self.function = function
    }

    public func with(_ arguments: GloballyEquatable...) -> Stub {
        self.arguments += arguments
        return self
    }

    public func andReturn(_ value: Any) {
        returnValue = value
    }
}

// MARK - Stubable Extension

public extension Stubable {
    func stub(_ function: String) -> Stub {
        let stub = Stub(function: function)
        _stubs.append(stub)

        return stub
    }

    func returnValue<T>(function: String = #function, arguments: GloballyEquatable...) -> T {
        return getReturnValue(function: function, arguments: arguments)
    }

    func returnValue<T>(asType _: T.Type, function: String = #function, arguments: GloballyEquatable...) -> T {
        return getReturnValue(function: function, arguments: arguments)
    }

    func returnValue<T>(withFallbackValue fallbackValue: T, function: String = #function, arguments: GloballyEquatable...) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        if stubsForFunctionName.isEmpty {
            return fallbackValue
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(specifiedArgs: stub.arguments, actualArgs: arguments), let value = stub.returnValue as? T {
                return value
            }
        }

        for stub in stubsWithoutArgs {
            if let value = stub.returnValue as? T {
                return value
            }
        }

        return fallbackValue
    }

    // MARK: - Protocol Extention Helper Functions

    private func getReturnValue<T>(function: String, arguments: [GloballyEquatable]) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        if stubsForFunctionName.isEmpty {
            let argumentsDescription = arguments.map{"<\($0)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(type(of: self)).\(function)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(T.self)>. Current stubs: <\(stubsForFunctionName)>.")
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(specifiedArgs: stub.arguments, actualArgs: arguments), let value = stub.returnValue as? T {
                return value
            }
        }

        for stub in stubsWithoutArgs {
            if let value = stub.returnValue as? T {
                return value
            }
        }

        let argumentsDescription = arguments.map{"<\($0)>"}.joined(separator: ", ")
        fatalError("No return value found for <\(type(of: self)).\(function)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(T.self)>. Current stubs: <\(stubsForFunctionName)>.")    }
}

// MARK: Private Extensions

extension Array {
    /**
     Splits the array into two separate arrays.

     - Parameter closure: The closure to determine which array each element will be put into. Return `true` to put item in first array and `false` to put it into the second array.
     */
    func bisect(_ closure: (Element) -> Bool) -> (Array<Element>, Array<Element>) {
        var arrays = ([Element](), [Element]())
        self.forEach { closure($0) ? arrays.0.append($0) : arrays.1.append($0) }

        return arrays
    }
}
