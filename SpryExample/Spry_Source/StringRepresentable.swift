//
//  StringRepresentable.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/7/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

public protocol StringRepresentable: RawRepresentable {
    var rawValue: String { get }
    init?(rawValue: String)
}

internal func fatalErrorOrFunction<T: StringRepresentable>(functionName: String, file: String, line: Int) -> T {
    guard let function = T(rawValue: functionName) else {
        let startingMessage = "function <\(functionName)> in file <\(file)> on line <\(line)> could not be turned into <\(T.self)>."

        if let probableCase = remove(originalString: functionName, startingCharacterToRemove: "(") {

            let probableMessage = "  [|] Possible Fix: case \(probableCase) = \"\(functionName)\""
            fatalError(startingMessage + "\n" + probableMessage + "\n")
        }

        fatalError(startingMessage)
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
