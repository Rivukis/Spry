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

    func returnValue<T>(function: String, arguments: Any...) -> T
    func returnValue<T>(asType _: T.Type, function: String, arguments: Any...) -> T
    func returnValue<T>(withFallbackValue fallbackValue: T, function: String, arguments: Any...) -> T
}

// MARK: - Helper Objects

public class Stub: CustomStringConvertible {
    enum StubType {
        case andReturn(Any)
        case andDo(([Any]) -> Any)
    }

    private var stubType: StubType?

    fileprivate let function: String
    fileprivate private(set) var arguments: [GloballyEquatable] = []

    fileprivate init(function: String) {
        self.function = function
    }

    // MARK: Public

    public var description: String {
        let argumentsString = arguments.map{"<\($0)>"}.joined(separator: ", ")
        let returnString = stubType == nil ? "nil" : "\(stubType!)"
        return "Stub(function: <\(function)>, args: <\(argumentsString)>, returnValue: <\(returnString)>)"
    }

    public func with(_ arguments: GloballyEquatable...) -> Stub {
        self.arguments += arguments
        return self
    }

    public func andReturn(_ value: Any) {
        stubType = .andReturn(value)
    }

    public func andDo(_ closure: @escaping ([Any]) -> Any) {
        stubType = .andDo(closure)
    }

    // MARK: Fileprivate

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

// MARK - Stubable Extension

public extension Stubable {
    func stub(_ function: String) -> Stub {
        let stub = Stub(function: function)
        _stubs.append(stub)

        return stub
    }

    func returnValue<T>(function: String = #function, arguments: Any...) -> T {
        return getReturnValue(function: function, arguments: arguments)
    }

    func returnValue<T>(asType _: T.Type, function: String = #function, arguments: Any...) -> T {
        return getReturnValue(function: function, arguments: arguments)
    }

    func returnValue<T>(withFallbackValue fallbackValue: T, function: String = #function, arguments: Any...) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        if stubsForFunctionName.isEmpty {
            return fallbackValue
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            let equatableArguments = arguments.map { $0 as! GloballyEquatable }
            if isEqualArgsLists(specifiedArgs: stub.arguments, actualArgs: equatableArguments), let value = stub.returnValue(for: arguments) as? T {
                return value
            }
        }

        for stub in stubsWithoutArgs {
            if let value = stub.returnValue(for: arguments) as? T {
                return value
            }
        }

        return fallbackValue
    }

    // MARK: - Protocol Extention Helper Functions

    private func getReturnValue<T>(function: String, arguments: [Any]) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        print(_stubs)
        print(function)

        if stubsForFunctionName.isEmpty {
            let argumentsDescription = arguments.map{"<\($0)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(type(of: self)).\(function)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(T.self)>. Current stubs: <\(stubsForFunctionName)>.")
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.arguments.count == 0 }

        for stub in stubsWithArgs {
            let equatableArguments = arguments.map { $0 as! GloballyEquatable }
            if isEqualArgsLists(specifiedArgs: stub.arguments, actualArgs: equatableArguments), let value = stub.returnValue(for: arguments) as? T {
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
