//
//  AtomicReference.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/4/18.
//  Copyright © 2018 Brian Radebaugh. All rights reserved.
//

import Foundation

internal enum ValueErrorCapture<T> {
    case value(T)
    case error(Error)

    func getValue() throws -> T {
        switch self {
        case .value(let value):
            return value
        case .error(let error):
            throw error
        }
    }
}

extension OperationQueue {
    /**
     A prettier version of adding a single `block` to an `OperationQueue` with the ability to specify `waitUntilFinished`.

     - parameter waitUntilFinished: Used to determine whether or not to block the caller until the added code block finishes execution
     - parameter block: The code block to execute
     */
    func addOperation(waitUntilFinished: Bool, block: @escaping () -> Void) {
        addOperations([BlockOperation(block: block)], waitUntilFinished: waitUntilFinished)
    }

    func unsafeSyncFunction<T>(block: @escaping () -> T) -> T {
        var result: T!
        addOperation(waitUntilFinished: true) {
            result = block()
        }

        return result
    }

    func throwingUnsafeSyncFunction<T>(block: @escaping () throws -> T) throws -> T {
        var valueErrorCapture: ValueErrorCapture<T>!

        addOperation(waitUntilFinished: true) {
            do {
                valueErrorCapture = .value(try block())
            } catch (let error) {
                valueErrorCapture = .error(error)
            }
        }

        return try valueErrorCapture.getValue()
    }

    /// Helps to prevent deadlocks by only adding a new operation to the non-concurrent private queue if the current queue is a different queue.
    func safeSyncFunction<T>(block: @escaping () -> T) -> T {
        if OperationQueue.current == self {
            return block()
        } else {
            return unsafeSyncFunction {
                return block()
            }
        }
    }

    /// Helps to prevent deadlocks by only adding a new operation to the non-concurrent private queue if the current queue is a different queue.
    func throwingSafeSyncFunction<T>(block: @escaping () throws -> T) throws -> T {
        if OperationQueue.current == self {
            return try block()
        } else {
            return try throwingUnsafeSyncFunction {
                return try block()
            }
        }
    }
}

/// A thread safe way of storing and accessing a shared value.
public class AtomicReference<T> {
    var value: T
    private let operationQueue: OperationQueue

    init(initialValue: T, objectName: String) {
        self.value = initialValue

        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.qualityOfService = .userInteractive
        self.operationQueue.name = "Non-concurrent queue used in Spry for object '\(objectName)'"
    }

    /// Used to atomically set the property to the `newValue`.
    public func set(newValue: T) {
        operationQueue.safeSyncFunction {
            self.value = newValue
        }
    }

    /// Used to atomically get the current value of the property.
    public func get() -> T {
        return operationQueue.safeSyncFunction {
            return self.value
        }
    }

    /// Used to atomically get a value derived from the current value of the property.
    public func getSubValue<U>(closure: @escaping (T) -> U) -> U {
        return operationQueue.safeSyncFunction {
            return closure(self.value)
        }
    }

    /// Used to atomically get the current value of the property in an atomic function.
    public func getAndDo(closure: @escaping (T) -> Void) {
        operationQueue.safeSyncFunction {
            closure(self.value)
        }
    }

    /// Used to atomically get the current value and supply a new value.
    public func getAndSetblah(closure: @escaping (T) -> T) {
        operationQueue.safeSyncFunction {
            self.value = closure(self.value)
        }
    }
}
