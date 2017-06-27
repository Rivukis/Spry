//
//  Stubber.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

public class Stub: CustomStringConvertible {
    let function: String
    private(set) var args: [GloballyEquatable] = []
    private(set) var returnValue: Any? = nil

    public var description: String {
        return "Stub(function: <\(function)>, args: <\(args.map{"<\($0)>"}.joined(separator: ", "))>, returnValue: <\(returnValue ?? "nil")>)"
    }

    init(function: String) {
        self.function = function
    }

    public func with(_ args: GloballyEquatable...) -> Stub {
        self.args += args
        return self
    }

    public func andReturn(_ value: Any) {
        returnValue = value
    }
}

public protocol Stubber : class {
    var _stubs: [Stub] { get set }

    func stub(_ function: String) -> Stub

    func returnValue<T>(function: String, args: GloballyEquatable...) -> T
    func returnValue<T>(asType _: T.Type, function: String, args: GloballyEquatable...) -> T
    func returnValue<T>(withFallbackValue fallbackValue: T, function: String, args: GloballyEquatable...) -> T
}

public extension Stubber {
    func stub(_ function: String) -> Stub {
        let stub = Stub(function: function)
        _stubs.append(stub)

        return stub
    }

    func returnValue<T>(function: String = #function, args: GloballyEquatable...) -> T {
        return getReturnValue(function: function, args: args)
    }

    func returnValue<T>(asType _: T.Type, function: String = #function, args: GloballyEquatable...) -> T {
        return getReturnValue(function: function, args: args)
    }

    func returnValue<T>(withFallbackValue fallbackValue: T, function: String = #function, args: GloballyEquatable...) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        if stubsForFunctionName.isEmpty {
            return fallbackValue
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.args.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(specifiedArgs: stub.args, actualArgs: args), let value = stub.returnValue as? T {
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

    // MARK: Helper

    private func getReturnValue<T>(function: String, args: [GloballyEquatable]) -> T {
        let stubsForFunctionName = _stubs.filter{ $0.function == function }

        if stubsForFunctionName.isEmpty {
            let argsDesc = args.map{"<\($0)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(type(of: self)).\(function)> on instance <\(self)> with received arguments <\(argsDesc)> returning <\(T.self)>. Current stubs: <\(stubsForFunctionName)>.")
        }

        let (stubsWithoutArgs, stubsWithArgs) = stubsForFunctionName.bisect{ $0.args.count == 0 }

        for stub in stubsWithArgs {
            if isEqualArgsLists(specifiedArgs: stub.args, actualArgs: args), let value = stub.returnValue as? T {
                return value
            }
        }

        for stub in stubsWithoutArgs {
            if let value = stub.returnValue as? T {
                return value
            }
        }

        let argsDesc = args.map{"<\($0)>"}.joined(separator: ", ")
        fatalError("No return value found for <\(type(of: self)).\(function)> on instance <\(self)> with received arguments <\(argsDesc)> returning <\(T.self)>. Current stubs: <\(stubsForFunctionName)>.")    }
}

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
