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
private final class StubSpecialString : SpecialString, Stubable {
    var _stubs = [Stub]()

    func myStringValue() -> String {
        return returnValue()
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
    func hereComesAClosure() -> () -> String
    func giveMeAnotherString() -> String
    func giveMeAnOptional() -> String?
    func giveMeAString(string: String) -> String
    func callThisCompletion(closure: () -> Void)
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

    func hereComesAClosure() -> () -> String {
        return { "a real string in a closure" }
    }

    func giveMeAnotherString() -> String {
        return "another real string"
    }

    func giveMeAnOptional() -> String? {
        return nil
    }

    func giveMeAString(string: String) -> String {
        return string
    }

    func callThisCompletion(closure: () -> Void) {

    }
}


// ********** stub the service **********

private class StubStringService : StringService, Stubable {
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

    func hereComesAClosure() -> () -> String {
        return returnValue()
    }

    func giveMeAnotherString() -> String {
        return returnValue(withFallbackValue: "fallback value")
    }

    func giveMeAnOptional() -> String? {
        return returnValue()
    }

    func giveMeAString(string: String) -> String {
        return returnValue(arguments: string)
    }

    func callThisCompletion(closure: () -> Void) {
        return returnValue(arguments: closure)
    }
}

// ********** object under test **********

private class TestObject {
    let service : StringService

    init(service: StringService) {
        self.service = service
    }

    func getAString() -> String {
        return self.service.giveMeAString()
    }

    func getBoolForTwoStrings(_ string1: String, _ string2: String) -> Bool {
        print(#function)
        return self.service.hereAreTwoStrings(string1: string1, string2: string2)
    }

    func turnTupleIntoString() -> String {
        let tuple = service.hereComesATuple()
        return tuple.0 + " " + tuple.1
    }

    func turnProtocolIntoString() -> String {
        return service.hereComesAProtocol().myStringValue()
    }

    func turnTupleOfProtocolsIntoString() -> String {
        let tuple = service.hereComesProtocolsInATuple()
        return tuple.0.myStringValue() + " " + tuple.1.myStringValue()
    }

    func getAStringFromAClosure() -> String {
        let stringClosure = service.hereComesAClosure()
        return stringClosure()
    }

    func getAnotherString() -> String {
        return service.giveMeAnotherString()
    }

    func getAnOptional() -> String? {
        return service.giveMeAnOptional()
    }

    func getAString(string: String) -> String {
        return service.giveMeAString(string: string)
    }

    func callThisCompletion(_ closure: () -> Void) {
        service.callThisCompletion(closure: closure)
    }
}

class StubableSpec: QuickSpec {
    override func spec() {

        describe("Stubable") {
            var stringService: StubStringService!
            var subject: TestObject!

            beforeEach {
                stringService = StubStringService()
                subject = TestObject(service: stringService)
            }

            describe("returning a simple value") {
                let expectedString = "expected"

                beforeEach {
                    stringService.stub("giveMeAString()").andReturn(expectedString)
                }

                it("should get a string from the stubbed service") {
                    expect(subject.getAString()).to(equal(expectedString))
                }
            }

            describe("returning a tuple") {
                beforeEach {
                    stringService.stub("hereComesATuple()").andReturn(("hello", "world"))
                }

                it("should use the tuple ids to specify stubbed values") {
                    expect(subject.turnTupleIntoString()).to(equal("hello world"))
                }
            }

            describe("returning a protocol - real object") {
                let expectedValue = NumbersOnly(value: 123)

                beforeEach {
                    stringService.stub("hereComesAProtocol()").andReturn(expectedValue)
                }

                it("should use the tuple ids to specify stubbed values") {
                    expect(subject.turnProtocolIntoString()).to(equal(expectedValue.myStringValue()))
                }
            }

            describe("returning a protocol - stubbed object") {
                let expectedValue = "hello there"

                beforeEach {
                    let specialString = StubSpecialString()
                    specialString.stub("myStringValue()").andReturn(expectedValue)

                    stringService.stub("hereComesAProtocol()").andReturn(specialString)
                }

                it("should use the tuple ids to specify stubbed values") {
                    expect(subject.turnProtocolIntoString()).to(equal(expectedValue))
                }
            }

            describe("returning a tuple of protocols") {
                let expectedFirstHalf = NumbersOnly(value: 1)
                let expectedSecondHalf = "two"

                beforeEach {
                    let secondHalfSpecialString = StubSpecialString()
                    secondHalfSpecialString.stub("myStringValue()").andReturn(expectedSecondHalf)

                    stringService.stub("hereComesProtocolsInATuple()").andReturn((expectedFirstHalf, secondHalfSpecialString))
                }

                it("should be able to use real and another stubbed object while passing in the tuple ids") {
                    expect(subject.turnTupleOfProtocolsIntoString()).to(equal("\(expectedFirstHalf.myStringValue()) \(expectedSecondHalf)"))
                }
            }

            describe("returning a closure") {
                let expectedString = "string from closure"

                beforeEach {
                    stringService.stub("hereComesAClosure()").andReturn({ expectedString })
                }

                it("should get a closure from the stubbed service") {
                    expect(subject.getAStringFromAClosure()).to(equal(expectedString))
                }
            }

            describe("returning an optional") {
                context("when stubbed with an optional") {
                    let expectedReturn: String? = "i should be returned"

                    beforeEach {
                        stringService.stub("giveMeAnOptional()").andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.getAnOptional()).to(equal(expectedReturn))
                    }
                }

                context("when stubbed with a NON-optional") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        stringService.stub("giveMeAnOptional()").andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.getAnOptional()).to(equal(expectedReturn))
                    }
                }
            }

            describe("passing in args") {
                context("when the args match what is stubbed") {
                    let expectedArg = "im expected"
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        stringService.stub("giveMeAString(string:)").with(expectedArg).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.getAString(string: expectedArg)).to(equal(expectedReturn))
                    }
                }

                context("when the args do NOT match what is stubbed") {
                    beforeEach {
                        stringService.stub("giveMeAString(string:)").with("not expected").andReturn("return value")
                    }

                    it("should fatal error") {
                        expect({_ = subject.getAString(string: "")}()).to(throwAssertion())
                    }
                }

                context("when there are no args passed in") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        stringService.stub("giveMeAString(string:)").andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.getAString(string: "doesn't matter")).to(equal(expectedReturn))
                    }
                }

                context("when using an argument specifier") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        stringService.stub("giveMeAString(string:)").with(Argument.instanceOf(type: String.self)).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.getAString(string: "any string should work")).to(equal(expectedReturn))
                    }
                }
            }

            describe("fallback value") {
                context("when the function is stubbed with the appropriate type") {
                    let expectedString = "stubbed value"

                    beforeEach {
                        stringService.stub("giveMeAnotherString()").andReturn(expectedString)
                    }

                    it("should return the stubbed value") {
                        expect(subject.getAnotherString()).to(equal(expectedString))
                    }
                }

                context("when the function is NOT stubbed with the appropriate type") {
                    beforeEach {
                        stringService.stub("giveMeAnotherString()").andReturn(100)
                    }

                    it("should return the fallback value") {
                        expect(subject.getAnotherString()).to(equal("fallback value"))
                    }
                }

                context("when the function is NOT stubbed") {
                    it("should return the fallback value") {
                        expect(subject.getAnotherString()).to(equal("fallback value"))
                    }
                }
            }

            describe("improper stubbing") {
                context("when the value is not stubbed") {
                    it("should fatal error") {
                        expect({ _ = subject.getAString() }()).to(throwAssertion())
                    }
                }

                context("when the value is stubbed with the wrong value") {
                    beforeEach {
                        stringService.stub("giveMeAString()").andReturn(50)
                    }

                    it("should fatal error") {
                        expect({ _ = subject.getAString() }()).to(throwAssertion())
                    }
                }
            }

            describe("and do") {
                context("when there are NO arguments") {
                    let expectedString = "expected"

                    beforeEach {
                        stringService.stub("giveMeAString()").andDo { _ in
                            return expectedString
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.getAString()).to(equal(expectedString))
                    }
                }

                context("when there are arguments") {
                    beforeEach {
                        stringService.stub("hereAreTwoStrings(string1:string2:)").andDo { arguments in
                            let string1 = arguments[0] as! String
                            let string2 = arguments[1] as! String

                            return string1 == "one" && string2 == "two"
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.getBoolForTwoStrings("one", "two")).to(beTrue())
                    }
                }

                context("when the are is a completion closure") {
                    var turnToTrue = false

                    beforeEach {
                        stringService.stub("callThisCompletion(closure:)").andDo { arguments in
                            let completion = arguments[0] as! () -> Void
                            completion()

                            return Void()
                        }

                        subject.callThisCompletion {
                            turnToTrue = true
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(turnToTrue).to(beTrue())
                    }
                }
            }
        }

    }
}
