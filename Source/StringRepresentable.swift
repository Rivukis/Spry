import Foundation

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

private let singleUnnamedArgumentFunctionaSuffix = "(_:)"

public extension StringRepresentable {
    init<T>(functionName: String, type: T.Type, file: String, line: Int) {
        let hasUnnamedArgumentSuffix = functionName.hasSuffix(singleUnnamedArgumentFunctionaSuffix)

        if let function = Self(rawValue: functionName) {
            self = function
        }
        else if hasUnnamedArgumentSuffix,
            let function = Self(rawValue: String(functionName.dropLast(singleUnnamedArgumentFunctionaSuffix.count))) {
            self = function
        }
        else if !hasUnnamedArgumentSuffix,
            let function = Self(rawValue: functionName + singleUnnamedArgumentFunctionaSuffix){
            self = function
        }
        else {
            Constant.FatalError.noFunctionFound(functionName: functionName, type: type, file: file, line: line)
        }
    }
}
