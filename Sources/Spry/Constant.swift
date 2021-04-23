import Foundation

private func fatalError(title: String, entries: [String]) -> Never {
    let titleString = "\n --- FATAL ERROR: \(title) ---"
    let entriesString = entries.map { "\n  ￫ " + $0 }.joined() + "\n"
    let errorString = titleString + entriesString

    SpryConfiguration.fatalErrorClosure(errorString)

    fatalError(errorString)
}

private func routeString(filePath: String, line: String) -> String {
    let file = filePath.components(separatedBy: "/").last ?? filePath

    return file + ":" + line
}

internal enum Constant {
    enum FatalError {
        static func wrongNumberOfArgsBeingCompared<T>(fakeType: T.Type, functionName: String, specifiedArguments: [SpryEquatable?], actualArguments: [Any?]) -> Never {
            let title = "Wrong number of arguments to compare"
            let entries = [
                "Type: \(T.self)",
                "Function: \(fakeType)",
                "Specified count: \(specifiedArguments.count)",
                "Received count: \(actualArguments.count)",
                "Specified arguments: \(descriptionOfArguments(specifiedArguments))",
                "Actual arguments: \(descriptionOfArguments(actualArguments))"
            ]

            fatalError(title: title, entries: entries)
        }

        static func doesNotConformToEquatable(_ value: SpryEquatable) -> Never {
            let title = "Improper SpryEquatable"
            let entries = [
                "\(type(of: value)) must either conform to Equatable or be changed to a reference type (i.e. class)"
            ]

            fatalError(title: title, entries: entries)
        }

        static func doesNotConformToSpryEquatable(_ value: Any) -> Never {
            let title = "SpryEquatable required"
            let entries = [
                "\(type(of: value)) must conform to SpryEquatable"
            ]

            fatalError(title: title, entries: entries)
        }

        static func shouldNotConformToOptionalType(_ value: Any) -> Never {
            let title = "Not allowed to conform to 'OptionalType'"
            let entries = [
                "Violating Type: \(type(of: value))",
                "Nothing should NOT conform to OptionalType. This is reserved for Optional<Wrapped>"
            ]

            fatalError(title: title, entries: entries)
        }

        static func argumentCaptorCouldNotReturnSpecifiedType<T>(value: Any?, type: T.Type) -> Never {
            let title = "Argument Capture: wrong argument type"
            let entries = [
                "Captured argument: \(value as Any)",
                "Specified type: \(T.self)"
            ]

            fatalError(title: title, entries: entries)
        }

        static func capturedArgumentsOutOfBounds(index: Int, capturedArguments: [Any?]) -> Never {
            let title = "Argument Capture: index out of bounds"
            let entries = [
                "Index \(index) is out of bounds for captured arguments",
                "Current captured arguments: \(descriptionOfArguments(capturedArguments))"
            ]

            fatalError(title: title, entries: entries)
        }

        static func noReturnValueFoundForInstanceFunction<S: Stubbable, R>(stubbable: S, function: S.Function, arguments: [Any?], returnType: R.Type) -> Never {
            noReturnValueFoundForFunction(stubbableType: S.self, functionName: function.rawValue, arguments: arguments, returnType: R.self, stubsDictionary: stubbable._stubsDictionary)
        }

        static func noReturnValueFoundForClassFunction<S: Stubbable, R>(stubbableType _: S.Type, function: S.ClassFunction, arguments: [Any?], returnType: R.Type) -> Never {
            noReturnValueFoundForFunction(stubbableType: S.self, functionName: function.rawValue, arguments: arguments, returnType: R.self, stubsDictionary: S._stubsDictionary)
        }

        static func noReturnValueSourceFound(functionName: String) -> Never {
            let title = "Incomplete Stub"
            let entries = [
                "Must add '.andReturn()', '.andDo()', or '.andThrow()' when stubbing a function"
            ]

            fatalError(title: title, entries: entries)
        }

        static func andThrowOnNonThrowingInstanceFunction<S: Stubbable>(stubbable: S, function: S.Function) -> Never {
            andThrowOnNonThrowingFunction(type: S.self, functionName: function.rawValue)
        }

        static func andThrowOnNonThrowingClassFunction<S: Stubbable>(stubbable: S.Type, function: S.ClassFunction) -> Never {
            andThrowOnNonThrowingFunction(type: S.self, functionName: function.rawValue)
        }

        static func noFunctionFound<T>(functionName: String, type: T.Type, file: String, line: Int) -> Never {
            let caseName = functionName.removeAfter(startingCharacter: "(") ?? functionName
            let probableMessage = "case \(caseName) = \"\(functionName)\""

            let title = "Unable to find function"
            let entries = [
                "Type: \(type)",
                "Function signature: \(functionName)",
                "Error occured on: \(routeString(filePath: file, line: "\(line)"))",
                "Possible Fix: ↴",
                probableMessage,
            ]

            fatalError(title: title, entries: entries)
        }

        static func stubbingSameFunctionWithSameArguments(stub: Stub) -> Never {
            let title = "Stubbing the same function with the same arguments"
            let entries = [
                "Function: \(stub.functionName)",
                "Arguments: \(descriptionOfArguments(stub.arguments))",
                "In most cases, stubbing the same function with the same arguments is a \"code smell\"",
                "However, if this is intentional then use `.stubAgain()`"
            ]

            fatalError(title: title, entries: entries)
        }

        // MARK: - Private

        private static func noReturnValueFoundForFunction<S, R>(stubbableType: S.Type, functionName: String, arguments: [Any?], returnType: R.Type, stubsDictionary: StubsDictionary) -> Never {
            let title = "No return value found"
            let entries = [
                "Stubbable: \(S.self)",
                "Function: \(functionName)",
                "Arguments: \(descriptionOfArguments(arguments))",
                "Return Type: \(R.self)",
                "Current stubs: \(stubsDictionary.stubs)"
            ]

            fatalError(title: title, entries: entries)
        }

        private static func andThrowOnNonThrowingFunction<T>(type: T.Type, functionName: String) -> Never {
            let title = "Used '.andThrow()' on non-throwing function"
            let entries = [
                "Stubbable: \(T.self)",
                "Function: \(functionName)",
                "If this function can throw, then ensure that the fake is calling 'spryifyThrows()' or 'stubbedValueThrows()' as the return value of this function."
            ]

            fatalError(title: title, entries: entries)
        }

        private static func descriptionOfArguments(_ arguments: [Any?]) -> String {
            return arguments
                .map{"<\($0 as Any)>"}
                .joined(separator: ", ")
        }
    }
}
