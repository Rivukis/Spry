import Foundation
import NSpry

struct StubbableError: Error, Equatable {
    let id: String

    public static func == (lhs: StubbableError, rhs: StubbableError) -> Bool {
        return lhs.id == rhs.id
    }
}

// basic protocol
protocol SpecialString {
    func myStringValue() -> String
}

// final class
final class AlwaysLowerCase: SpecialString {
    let value: String

    init(value: String) {
        self.value = value
    }

    func myStringValue() -> String {
        return value.lowercased()
    }
}

// Non-final class
class NumbersOnly: SpecialString {
    let value: Int

    required init(value: Int) {
        self.value = value
    }

    func myStringValue() -> String {
        return String(value)
    }
}

// stubbed version
final class StubSpecialString: SpecialString, Stubbable {
    enum ClassFunction: String, StringRepresentable {
        case none
    }

    enum Function: String, StringRepresentable {
        case myStringValue = "myStringValue()"
    }

    func myStringValue() -> String {
        return stubbedValue()
    }
}

// protocol with self or associated type requirements
protocol ProtocolWithSelfRequirement {
    func me() -> Self
}

final class ProtocolWithSelfRequirementImplemented: ProtocolWithSelfRequirement {
    func me() -> ProtocolWithSelfRequirementImplemented {
        return self
    }
}

// Stubbable example class
class StubbableTestHelper: Stubbable {
    enum ClassFunction: String, StringRepresentable {
        case classFunction = "classFunction()"
    }

    enum Function: String, StringRepresentable {
        case myProperty
        case giveMeAString = "giveMeAString()"
        case hereAreTwoStrings = "hereAreTwoStrings(string1:string2:)"
        case hereComesATuple = "hereComesATuple()"
        case hereComesAProtocol = "hereComesAProtocol()"
        case hereComesProtocolsInATuple = "hereComesProtocolsInATuple()"
        case hereComesProtocolWithSelfRequirements = "hereComesProtocolWithSelfRequirements(object:)"
        case hereComesAClosure = "hereComesAClosure()"
        case giveMeAStringWithFallbackValue = "giveMeAStringWithFallbackValue()"
        case giveMeAnOptional = "giveMeAnOptional()"
        case giveMeAString_string = "giveMeAString(string:)"
        case giveMeAVoid = "giveMeAVoid()"
        case takeAnOptionalString = "takeAnOptionalString(string:)"
        case takeUnnamedArgument = "takeUnnamedArgument(_:)"
        case callThisCompletion = "callThisCompletion(string:closure:)"
        case throwingFunction = "throwingFunction()"
    }

    var myProperty: String {
        return stubbedValue()
    }

    func giveMeAString() -> String {
        return stubbedValue()
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        return stubbedValue(arguments: string1, string2)
    }

    func hereComesATuple() -> (String, String) {
        return stubbedValue()
    }

    func hereComesAProtocol() -> SpecialString {
        return stubbedValue()
    }

    func hereComesProtocolsInATuple() -> (SpecialString, SpecialString) {
        return stubbedValue()
    }

    func hereComesProtocolWithSelfRequirements<T: ProtocolWithSelfRequirement>(object: T) -> T {
        return stubbedValue()
    }

    func hereComesAClosure() -> () -> String {
        return stubbedValue()
    }

    var fallbackValueForgiveMeAStringWithFallbackValue: String?
    func giveMeAStringWithFallbackValue() -> String? {
        return stubbedValue(fallbackValue: fallbackValueForgiveMeAStringWithFallbackValue)
    }

    func giveMeAnOptional() -> String? {
        return stubbedValue()
    }

    func giveMeAString(string: String) -> String {
        return stubbedValue(arguments: string)
    }

    func giveMeAVoid() {
        return stubbedValue()
    }

    func takeAnOptionalString(string: String?) -> String {
        return stubbedValue(arguments: string)
    }

    func takeUnnamedArgument(_ unnamed: String) -> Bool {
        return stubbedValue(arguments: unnamed)
    }

    func callThisCompletion(string: String, closure: @escaping () -> Void) {
        return stubbedValue(arguments: string, closure)
    }

    func throwingFunction() throws {
        return try stubbedValueThrows()
    }

    static func classFunction() -> String {
        return stubbedValue()
    }
}
