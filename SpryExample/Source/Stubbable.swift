//
//  Stubbable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 8/1/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

import Foundation

public protocol Stubbable: class {
    var _stubs: [Stub] { get set }

    func stub(_ function: String) -> Stub

    func stubbedValue<T>(function: String, arguments: Any..., asType _: T.Type) -> T
    func stubbedValue<T>(function: String, arguments: Any..., fallbackValue: T) -> T
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
    func bisect(_ closure: (Element) -> Bool) -> (Array<Element>, Array<Element>) {
        var arrays = ([Element](), [Element]())
        self.forEach { closure($0) ? arrays.0.append($0) : arrays.1.append($0) }

        return arrays
    }
}
