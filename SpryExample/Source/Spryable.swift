import Foundation

public protocol Spryable: Spyable, Stubbable {
    func spryify<T>(function: String, arguments: GloballyEquatable..., asType _: T.Type) -> T
    func spryify<T>(function: String, arguments: GloballyEquatable..., fallbackValue: T) -> T
}

public extension Spryable {
    func spryify<T>(function: String = #function, arguments: GloballyEquatable..., asType _: T.Type = T.self) -> T {
        internal_recordCall(function: function, arguments: arguments)
        return internal_returnValue(function: function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(function: String = #function, arguments: GloballyEquatable..., fallbackValue: T) -> T {
        internal_recordCall(function: function, arguments: arguments)
        return internal_returnValue(function: function, arguments: arguments, fallback: .fallback(fallbackValue))
    }
}
