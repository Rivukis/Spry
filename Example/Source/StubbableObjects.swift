//
//  Stub.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/16/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 Object return by `stub()` call. Used to specify arguments and return values when stubbing.
 */

public class Stub: CustomStringConvertible {
    enum StubType {
        case andReturn(Any?)
        case andDo(([Any?]) -> Any?)
        case andThrow(Error)
    }

    // MARK: - Public Properties

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        let argumentsDescription = arguments.map{"<\($0)>"}.joined(separator: ", ")
        let returnDescription = isNil(stubType) ? "nil" : "\(stubType!)"

        return "Stub(function: <\(functionName)>, args: <\(argumentsDescription)>, returnValue: <\(returnDescription)>)"
    }

    /// A beautified description. Used for logging.
    public var friendlyDescription: String {
        let functionStringRepresentation = "<" + functionName + ">"
        let arguementListStringRepresentation = arguments
            .map { "<\($0)>" }
            .joined(separator: ", ")

        if !arguementListStringRepresentation.isEmpty {
            return functionStringRepresentation + " with " + arguementListStringRepresentation
        }

        return functionStringRepresentation
    }

    // MARK: - Internal Properties

    let functionName: String

    var isComplete: Bool {
        return stubType != nil
    }

    private(set) var arguments: [SpryEquatable] = []
    var chronologicalIndex = -1

    // MARK: - Private Properties

    private var stubType: StubType? {
        didSet {
            if stubType != nil {
                stubCompleteHandler(self)
            }
        }
    }

    private var stubCompleteHandler: (Stub) -> Void

    // MARK: - Initializers

    init(functionName: String, stubCompleteHandler: @escaping (Stub) -> Void) {
        self.functionName = functionName
        self.stubCompleteHandler = stubCompleteHandler
    }

    // MARK: - Public Functions

    /**
     Used to specify arguments when stubbing.

     - Note: If no arguments are specified then any arguments may be passed in and the stubbed value will still be returned.

     ## Example ##
     ```swift
     service.stub("functionSignature").with("expected argument")
     ```

     - Parameter arguments: The specified arguments needed for the stub to succeed. See `Argument` for ways other ways of constraining expected arguments besides Equatable.

     - Returns: A stub object used to add additional `with()` or to add `andReturn()` or `andDo()`.
     */
    public func with(_ arguments: SpryEquatable...) -> Stub {
        self.arguments += arguments
        return self
    }

    /**
     Used to specify the return value for the stubbed function.

     - Important: This allows `Any` object to be passed in but the stub will ONLY work if the correct type is passed in.

     - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).

     ## Example ##
     ```swift
     // arguments do NOT matter
     service.stub(.functionSignature).andReturn("stubbed value")

     // arguments matter
     service.stub(.functionSignature).with("expected argument").andReturn("stubbed value")
     ```

     - Parameter value: The value to be returned by the stubbed function.
     */
    public func andReturn(_ value: Any? = Void()) {
        stubType = .andReturn(value)
    }

    /**
     Used to specify a closure to be executed in place of the stubbed function.

     - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).

     ## Example ##
     ```swift
     // arguments do NOT matter (closure will be called if `functionSignature()` is called)
     service.stub(.functionSignature).andDo { arguments in
         // do test specific things (like call a completion block)
         return "stubbed value"
     }

     // arguments matter (closure will NOT be called unless the arguments match what is passed in the `with()` function)
     service.stub(.functionSignature).with("expected argument").andDo { arguments in
         // do test specific things (like call a completion block)
         return "stubbed value"
     }
     ```

     - Parameter closure: The closure to be executed. The array of parameters that will be passed in correspond to the parameters being passed into the stubbed function. The return value must match the stubbed function's return type and will be the return value of the stubbed function.
     */
    public func andDo(_ closure: @escaping ([Any?]) -> Any?) {
        stubType = .andDo(closure)
    }

    /**
     Used to throw a Swift `Error` for the stubbed function.

     - Important: Only use this on functions that can throw an Error. Must return `SpryifyThrows()` or `StubbedValueThrows()` in throwing functions when making a fake object.

     - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).

     ## Example ##
     ```swift
     // arguments do NOT matter
     service.stub(.functionSignatureOfThrowingFunction).andThrow(CustomSwiftError())

     // arguments matter
     service.stub(.functionSignatureOfThrowingFunction).with("expected argument").andReturn(CustomSwiftError())
     ```

     - Parameter error: The error to be thrown by the stubbed function.
     */
    public func andThrow(_ error: Error) {
        stubType = .andThrow(error)
    }

    // MARK: - Internal Functions

    internal func returnValue(for args: [Any?]) throws -> Any? {
        guard let stubType = stubType else {
            Constant.FatalError.noReturnValueSourceFound(functionName: functionName)
        }

        switch stubType {
        case .andReturn(let value):
            return value
        case .andDo(let closure):
            return closure(args)
        case .andThrow(let error):
            throw error
        }
    }

    internal func hasEqualBase(as stub: Stub) -> Bool {
        return self.functionName == stub.functionName
            && self.arguments._isEqual(to: stub.arguments as SpryEquatable)
    }
}

/**
 This exists because a dictionary is needed as a class. Instances of this type are put into an NSMapTable.
 */
public class StubsDictionary: CustomStringConvertible {

    // MARK: - Public Properties

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        return String(describing: stubsDict)
    }

    /// A beautified description. Used for logging.
    public var friendlyDescription: String {
        guard !stubs.isEmpty else {
            return "<>"
        }

        let friendlyStubsString = stubs
            .map { $0.friendlyDescription }
            .joined(separator: "; ")

        return friendlyStubsString
    }

    /// Array of all stubs in chronological order.
    public var stubs: [Stub] {
        return stubsDict
            .values
            .flatMap { $0 }
            .sorted { $0.chronologicalIndex < $1.chronologicalIndex }
    }

    /// Number of stubs that have been added. This number is NOT reset when stubs are removed (i.e. `stubAgain()`, `resetStubs()`)
    public private(set) var stubsCount = 0

    // MARK: - Private Properties

    private var stubsDict: [String: [Stub]] = [:]

    func add(stub: Stub) {
        var stubs = stubsDict[stub.functionName] ?? []

        stubsCount += 1
        stub.chronologicalIndex = stubsCount

        stubs.insert(stub, at: 0)
        stubsDict[stub.functionName] = stubs
    }

    func completedDuplicates(of stub: Stub) -> [Stub] {
        var duplicates: [Stub] = []

        stubsDict[stub.functionName]?.forEach {
            guard $0.chronologicalIndex != stub.chronologicalIndex && stub.isComplete else {
                return
            }

            if $0.hasEqualBase(as: stub) {
                duplicates.append($0)
            }
        }

        return duplicates
    }

    func getStubs(for functionName: String) -> [Stub] {
        return stubsDict[functionName] ?? []
    }

    func remove(stubs removingStubs: [Stub], forFunctionName functionName: String) {
        var currentStubs = stubsDict[functionName] ?? []

        removingStubs.forEach { removedStub in
            currentStubs.removeFirst { currentStub in
                return currentStub.chronologicalIndex == removedStub.chronologicalIndex
            }
        }

        stubsDict[functionName] = currentStubs
    }

    func clearAllStubs() {
        stubsDict = [:]
    }
}

/**
 Used to determine if a fallback was given in the event of that no stub is found.
 */
internal enum Fallback<T> {
    case noFallback
    case fallback(T)
}
