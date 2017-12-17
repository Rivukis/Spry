//
//  StringRepresentable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/7/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

/**
 This protocol is how the function name string gets converted to a type.
 
 It's easiest to have an enum with a raw type of `String`. Said type only needs to say it conforms to this protocol.
 
 ## Example ##
 ```swift
 enum Function: String, StringRepresentable {
     // ...
 }
 ```
 */
public protocol StringRepresentable: RawRepresentable {
    var rawValue: String { get }
    init?(rawValue: String)
    init<T>(functionName: String, type: T.Type, file: String, line: Int)
}

public extension StringRepresentable {
    public init<T>(functionName: String, type: T.Type, file: String, line: Int) {
        guard let function = Self(rawValue: functionName) else {
            Constant.FatalError.noFunctionFound(functionName: functionName, type: type, file: file, line: line)
        }

        self = function
    }
}
