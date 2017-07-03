import Quick
import Nimble
import SpryExample

// ********** a protocol as a return value **********

private protocol SpecialString {
    func myStringValue() -> String
}

// final
private final class AlwaysLowerCase: SpecialString {
    let value: String

    init(value: String) {
        self.value = value
    }

    func myStringValue() -> String {
        return value.lowercased()
    }
}

// NOT final
private class NumbersOnly: SpecialString {
    let value: Int

    required init(value: Int) {
        self.value = value
    }

    func myStringValue() -> String {
        return String(value)
    }
}

// stubbed version
private final class StubSpecialString : SpecialString, Stubbable {
    var _stubs = [Stub]()

    func myStringValue() -> String {
        return returnValue()
    }
}

// protocol with self or associated type requirements

private protocol ProtocolWithSelfRequirement {
    func me() -> Self
}

private final class MyClass: ProtocolWithSelfRequirement {
    func me() -> MyClass {
        return self
    }
}

// ********** the service to be stubbed **********

// The Protocol
private protocol StringService : class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String) -> Bool
    func hereComesATuple() -> (String, String)
    func hereComesAProtocol() -> SpecialString
    func hereComesProtocolsInATuple() -> (SpecialString, SpecialString)
    func hereComesProtocolWithSelfRequirements<T: ProtocolWithSelfRequirement>(object: T) -> T
    func hereComesAClosure() -> () -> String
    func giveMeAStringWithFallbackValue() -> String
    func giveMeAnOptional() -> String?
    func giveMeAString(string: String) -> String
    func callThisCompletion(string: String, closure: () -> Void)
}

// The Real Class
private class RealStringService : StringService {
    func giveMeAString() -> String {
        return "a real string"
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        // do real stuff with strings
        return true
    }

    func hereComesATuple() -> (String, String) {
        return ("first real value", "second real value")
    }

    func hereComesAProtocol() -> SpecialString {
        return NumbersOnly(value: 12345)
    }

    func hereComesProtocolsInATuple() -> (SpecialString, SpecialString) {
        return (NumbersOnly(value: 123), AlwaysLowerCase(value: "2nd real value"))
    }

    func hereComesProtocolWithSelfRequirements<T: ProtocolWithSelfRequirement>(object: T) -> T {
        return object
    }

    func hereComesAClosure() -> () -> String {
        return { "a real string in a closure" }
    }

    func giveMeAStringWithFallbackValue() -> String {
        return "another real string"
    }

    func giveMeAnOptional() -> String? {
        return nil
    }

    func giveMeAString(string: String) -> String {
        return string
    }

    func callThisCompletion(string: String, closure: () -> Void) {

    }
}


// ********** stub the service **********

private class StubStringService : StringService, Stubbable {
    var _stubs = [Stub]()

    func giveMeAString() -> String {
        return returnValue()
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        return returnValue(arguments: string1, string2)
    }

    func hereComesATuple() -> (String, String) {
        return returnValue()
    }

    func hereComesAProtocol() -> SpecialString {
        return returnValue()
    }

    func hereComesProtocolsInATuple() -> (SpecialString, SpecialString) {
        return returnValue()
    }

    func hereComesProtocolWithSelfRequirements<T: ProtocolWithSelfRequirement>(object: T) -> T {
        return returnValue()
    }

    func hereComesAClosure() -> () -> String {
        return returnValue()
    }

    func giveMeAStringWithFallbackValue() -> String {
        return returnValue(fallbackValue: "fallback value")
    }

    func giveMeAnOptional() -> String? {
        return returnValue()
    }

    func giveMeAString(string: String) -> String {
        return returnValue(arguments: string)
    }

    func callThisCompletion(string: String, closure: () -> Void) {
        return returnValue(arguments: string, closure)
    }
}

class StubbableSpec: QuickSpec {
    override func spec() {

        describe("Stubbable") {
            var subject: StubStringService!

            beforeEach {
                subject = StubStringService()
            }

            describe("returning a simple value") {
                let expectedString = "expected"

                beforeEach {
                    subject.stub("giveMeAString()").andReturn(expectedString)
                }

                it("should get a string from the stubbed service") {
                    expect(subject.giveMeAString()).to(equal(expectedString))
                }
            }

            describe("returning a tuple") {
                beforeEach {
                    subject.stub("hereComesATuple()").andReturn(("hello", "world"))
                }

                it("should be able to stub a tuple return type") {
                    let tuple = subject.hereComesATuple()
                    expect(tuple.0).to(equal("hello"))
                    expect(tuple.1).to(equal("world"))
                }
            }

            describe("returning a protocol - real object") {
                let expectedValue = NumbersOnly(value: 123)

                beforeEach {
                    subject.stub("hereComesAProtocol()").andReturn(expectedValue)
                }

                it("should be able to stub a protocol return type") {
                    let specialString = subject.hereComesAProtocol()
                    expect(specialString.myStringValue()).to(equal(expectedValue.myStringValue()))
                }
            }

            describe("returning a protocol - stubbed object") {
                let expectedValue = "hello there"

                beforeEach {
                    let specialString = StubSpecialString()
                    specialString.stub("myStringValue()").andReturn(expectedValue)

                    subject.stub("hereComesAProtocol()").andReturn(specialString)
                }

                it("should be able to stub a tuple of protocols as a return type") {
                    let specialString = subject.hereComesAProtocol()
                    expect(specialString.myStringValue()).to(equal(expectedValue))
                }
            }

            describe("returning a tuple of protocols") {
                let expectedFirstHalf = NumbersOnly(value: 1)
                let expectedSecondHalf = "two"

                beforeEach {
                    let secondHalfSpecialString = StubSpecialString()
                    secondHalfSpecialString.stub("myStringValue()").andReturn(expectedSecondHalf)

                    subject.stub("hereComesProtocolsInATuple()").andReturn((expectedFirstHalf, secondHalfSpecialString))
                }

                it("should be able to use real and another stubbed object") {
                    let tuple = subject.hereComesProtocolsInATuple()
                    expect(tuple.0.myStringValue()).to(equal(expectedFirstHalf.myStringValue()))
                    expect(tuple.1.myStringValue()).to(equal(expectedSecondHalf))
                }
            }

            describe("returning a protocol with self or associated type requirements") {
                let expectedMyClass = MyClass()

                beforeEach {
                    subject.stub("hereComesProtocolWithSelfRequirements(object:)").andReturn(expectedMyClass)
                }

                it("should be able to stub a tuple of protocols as a return type") {
                    let actualMyClass = subject.hereComesProtocolWithSelfRequirements(object: MyClass())
                    expect(actualMyClass).to(beIdenticalTo(expectedMyClass))
                }
            }

            describe("returning a closure") {
                let expectedString = "string from closure"

                beforeEach {
                    subject.stub("hereComesAClosure()").andReturn({ expectedString })
                }

                it("should get a closure from the stubbed service") {
                    let closure = subject.hereComesAClosure()
                    expect(closure()).to(equal(expectedString))
                }
            }

            describe("returning an optional") {
                context("when stubbed with an optional") {
                    let expectedReturn: String? = "i should be returned"

                    beforeEach {
                        subject.stub("giveMeAnOptional()").andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAnOptional()).to(equal(expectedReturn))
                    }
                }

                context("when stubbed with a NON-optional") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub("giveMeAnOptional()").andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAnOptional()).to(equal(expectedReturn))
                    }
                }
            }

            describe("passing in args") {
                context("when the args match what is stubbed") {
                    let expectedArg = "im expected"
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub("giveMeAString(string:)").with(expectedArg).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAString(string: expectedArg)).to(equal(expectedReturn))
                    }
                }

                context("when the args do NOT match what is stubbed") {
                    beforeEach {
                        subject.stub("giveMeAString(string:)").with("not expected").andReturn("return value")
                    }

                    it("should fatal error") {
                        expect({_ = subject.giveMeAString(string: "")}()).to(throwAssertion())
                    }
                }

                context("when there are no args passed in") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub("giveMeAString(string:)").andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAString(string: "doesn't matter")).to(equal(expectedReturn))
                    }
                }

                context("when using an argument specifier") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub("giveMeAString(string:)").with(Argument.instanceOf(type: String.self)).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAString(string: "any string should work")).to(equal(expectedReturn))
                    }
                }
            }

            describe("fallback value") {
                context("when the function is stubbed with the appropriate type") {
                    let expectedString = "stubbed value"

                    beforeEach {
                        subject.stub("giveMeAStringWithFallbackValue()").andReturn(expectedString)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(equal(expectedString))
                    }
                }

                context("when the function is NOT stubbed with the appropriate type") {
                    beforeEach {
                        subject.stub("giveMeAStringWithFallbackValue()").andReturn(100)
                    }

                    it("should return the fallback value") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(equal("fallback value"))
                    }
                }

                context("when the function is NOT stubbed") {
                    it("should return the fallback value") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(equal("fallback value"))
                    }
                }
            }

            describe("improper stubbing") {
                context("when the value is not stubbed") {
                    it("should fatal error") {
                        expect({ _ = subject.giveMeAString() }()).to(throwAssertion())
                    }
                }

                context("when the value is stubbed with the wrong type") {
                    beforeEach {
                        subject.stub("giveMeAString()").andReturn(50)
                    }

                    it("should fatal error") {
                        expect({ _ = subject.giveMeAString() }()).to(throwAssertion())
                    }
                }
            }

            describe("and do") {
                context("when there are NO arguments") {
                    let expectedString = "expected"

                    beforeEach {
                        subject.stub("giveMeAString()").andDo { _ in
                            return expectedString
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.giveMeAString()).to(equal(expectedString))
                    }
                }

                describe("respecting passed in arguments and the return value") {
                    beforeEach {
                        subject.stub("hereAreTwoStrings(string1:string2:)").andDo { arguments in
                            let string1 = arguments[0] as! String
                            let string2 = arguments[1] as! String

                            return string1 == "one" && string2 == "two"
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.hereAreTwoStrings(string1: "one", string2: "two")).to(beTrue())
                    }
                }

                describe("manually manipulating agruments (such as passed in closures)") {
                    var turnToTrue = false

                    beforeEach {
                        subject.stub("callThisCompletion(string:closure:)").andDo { arguments in
                            let completion = arguments[1] as! () -> Void
                            completion()

                            return Void()
                        }

                        subject.callThisCompletion(string: "") {
                            turnToTrue = true
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(turnToTrue).to(beTrue())
                    }
                }

                describe("verifying arguments") {
                    context("when the arguments match") {
                        var turnToTrue = false

                        beforeEach {
                            let expectedargument = "expectedargument"
                            subject.stub("callThisCompletion(string:closure:)").with(expectedargument, Argument.anything).andDo { arguments in
                                let completion = arguments[1] as! () -> Void
                                completion()

                                return Void()
                            }

                            subject.callThisCompletion(string: expectedargument) {
                                turnToTrue = true
                            }
                        }

                        it("should get a string from the stubbed service") {
                            expect(turnToTrue).to(beTrue())
                        }
                    }

                    context("when the arguments do NOT match") {
                        beforeEach {
                            subject.stub("hereAreTwoStrings(string1:string2:)").with("what is needed", Argument.anything).andDo { _ in
                                return Void()
                            }
                        }

                        it("should fatal error when calling function") {
                            let expectedFatalErrorClosure = { _ = subject.hereAreTwoStrings(string1: "the wrong value", string2: "") }
                            expect(expectedFatalErrorClosure()).to(throwAssertion())
                        }
                    }
                }
            }
        }

    }
}
