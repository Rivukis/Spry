import Foundation

/**
 Convenience protocol to conform to and use Spyable and Stubbable protocols with less effort.

 See Spyable and Stubbable or more information.
 */

public protocol Spryable: Spyable, Stubbable {
    /**
     Convenience property to help conform to Spyable and Stubbable with less effort.

     See Spyable and Stubbable or more information.

     ## Example Conformance ##
     ```swift
     var _spry: (calls: [RecordedCall], stubs: [Stub]) = ([], [])
     ```
     */
    var _spry: (calls: [RecordedCall], stubs: [Stub]) { get set }

    /**
     Convenience function to record a call and return the stubbed value.

     See Spyable and Stubbable or more information.
     */
    func spryify<T>(function: String, arguments: GloballyEquatable..., asType _: T.Type) -> T

    /**
     Convenience function to record a call and return the stubbed value.

     See Spyable and Stubbable or more information.
     */
    func spryify<T>(function: String, arguments: GloballyEquatable..., fallbackValue: T) -> T
}

public extension Spryable {
    public var _calls: [RecordedCall] {
        get {
            return _spry.calls
        }
        set {
            _spry.calls = newValue
        }
    }

    public var _stubs: [Stub] {
        get {
            return _spry.stubs
        }
        set {
            _spry.stubs = newValue
        }
    }

    func spryify<T>(function: String = #function, arguments: GloballyEquatable..., asType _: T.Type = T.self) -> T {
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function: function, arguments: arguments, fallback: .noFallback)
    }

    func spryify<T>(function: String = #function, arguments: GloballyEquatable..., fallbackValue: T) -> T {
        internal_recordCall(function: function, arguments: arguments)
        return internal_stubbedValue(function: function, arguments: arguments, fallback: .fallback(fallbackValue))
    }
}
