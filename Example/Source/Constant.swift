import Foundation

internal enum Constant {
    enum FatalError {
        static func wrongTypesBeingCompared(_ actual: SpryEquatable?, _ me: SpryEquatable) -> Never {
            fatalError("Unable to equate type \(type(of: actual)) to \(type(of: me)).")
        }

        static func wrongNumberOfArgsBeingCompared(expectedCount: Int, actualCount: Int) -> Never {
            fatalError("Expected to compare \(expectedCount) arguments, got \(actualCount) arguments.")
        }

        static func doesNotConformToEquatable(_ value: SpryEquatable) -> Never {
            fatalError("\(type(of: value)) does NOT conform to Equatable. Conforming to Equatable is required for SpryEquatable.")
        }

        static func doesNotConformToSpryEquatable(_ value: Any) -> Never {
            fatalError("\(type(of: value)) does NOT conform to SpryEquatable.")
        }

        static func shouldNotConformToOptionalType(_ value: Any) -> Never {
            fatalError("\(type(of: value)) should NOT conform to OptionalType. This is reserved for Optional<Wrapped>.")
        }

        static func argumentCaptorCouldNotReturnSpecifiedType<T>(value: Any?, type: T.Type) -> Never {
            fatalError("Could not cast captured argument <\(String(describing: value))> to type <\(T.self)>.")
        }

        static func capturedArgumentsOutOfBounds(index: Int, count: Int) -> Never {
            fatalError("index <\(index)> is out of bounds for captured arguments count of <\(count)>.")
        }

        static func noReturnValueFoundForInstanceFunction<S: Stubbable, R>(stubbable: S, function: S.Function, arguments: [Any?], returnType: R.Type) -> Never {
            let argumentsDescription = arguments.map{"<\($0 as Any)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(S.self).\(function.rawValue)> on instance <\(stubbable)> with received arguments <\(argumentsDescription)> returning <\(R.self)>. Current stubs: <\(stubbable._stubs)>.")
        }

        static func noReturnValueFoundForClassFunction<S: Stubbable, R>(stubbableType _: S.Type, function: S.ClassFunction, arguments: [Any?], returnType: R.Type) -> Never {
            let argumentsDescription = arguments.map{"<\($0 as Any)>"}.joined(separator: ", ")
            fatalError("No return value found for <\(S.self).\(function.rawValue)> on instance <\(self)> with received arguments <\(argumentsDescription)> returning <\(R.self)>. Current stubs: <\(S._stubs)>.")
        }

        static func noReturnValueSourceFound() -> Never {
            fatalError("Must add `andReturn` or `andDo` to properly stub an object")
        }

        static func andThrowOnNonThrowingInstanceFunction<S: Stubbable>(stubbable: S, function: S.Function) -> Never {
            fatalError("Not allowed to use '.andThrow' on non-throwing function \(function.rawValue) on \(S.self)")
        }

        static func andThrowOnNonThrowingClassFunction<S: Stubbable>(stubbable: S.Type, function: S.ClassFunction) -> Never {
            fatalError("Not allowed to use '.andThrow' on non-throwing function \(function.rawValue) on \(S.self)")
        }
    }
}
