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
}

internal func fatalErrorOrFunction<T: StringRepresentable>(functionName: String, file: String, line: Int) -> T {
    guard let function = T(rawValue: functionName) else {
        let startingMessage = "function <\(functionName)> in file <\(file)> on line <\(line)> could not be turned into <\(T.self)>."

        if let probableFunctionCase = remove(originalString: functionName, startingCharacterToRemove: "(") {
            let probableMessage = "  [|] Possible Fix: case \(probableFunctionCase) = \"\(functionName)\""
            fatalError(startingMessage + "\n" + probableMessage + "\n")
        }

        let probableMessage = "  [|] Possible Fix: case \(functionName) = \"\(functionName)\""

        fatalError(startingMessage + "\n" + probableMessage)
    }

    return function
}

private func remove(originalString: String, startingCharacterToRemove character: String) -> String? {
    let range = originalString.range(of: character)
    if let lowerBound = range?.lowerBound {
        return originalString.substring(to: lowerBound)
    }

    return nil
}
