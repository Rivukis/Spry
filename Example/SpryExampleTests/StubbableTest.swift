//
//  StubbableTest.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 8/1/16.
//  Copyright © 2016 Brian Radebaugh. All rights reserved.
//

import Quick
import Nimble
import SpryExample

private class MyNonSpryEquatableClass {}

private class MyAnyObject: SpryEquatable {}

private struct MyEquatable: Equatable, SpryEquatable {
    let string: String

    public static func == (lhs: MyEquatable, rhs: MyEquatable) -> Bool {
        return lhs.string == rhs.string
    }
}

private class MyAnyObjectEquatable: Equatable, SpryEquatable {
    let string: String

    init(string: String) {
        self.string = string
    }

    public static func == (lhs: MyAnyObjectEquatable, rhs: MyAnyObjectEquatable) -> Bool {
        return lhs.string == rhs.string
    }
}

// MARK: - Test Helper Protocols

private protocol SpecialString {
    func myStringValue() -> String
}

// final class
private final class AlwaysLowerCase: SpecialString {
    let value: String

    init(value: String) {
        self.value = value
    }

    func myStringValue() -> String {
        return value.lowercased()
    }
}

// Non-final class
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
private final class StubSpecialString: SpecialString, Stubbable {
    enum StaticFunction: String, StringRepresentable {
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
private protocol ProtocolWithSelfRequirement {
    func me() -> Self
}

private final class MyClass: ProtocolWithSelfRequirement {
    func me() -> MyClass {
        return self
    }
}

// ********** the service to be stubbed **********

// MARK: - The Protocol
private protocol StringService: class {
    var myProperty: String { get }

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
    func takeAnArrayOfSpryEquatable(array: [Int]) -> String
    func takeAnArrayOfNonSpryEquatable(array: [MyNonSpryEquatableClass]) -> String
    func takeADictionaryOfSpryEquatable(dictionary: [String: Int]) -> String
    func takeADictionaryOfNonSpryEquatable(dictionary: [String: MyNonSpryEquatableClass]) -> String
    func takeAnEquatable(anEquatable: MyEquatable) -> String
    func takeAnAnyObject(anAnyObject: MyAnyObject) -> String
    func takeAnAnyObjectAndEquatable(anAnyObjectAndEquatable: MyAnyObjectEquatable) -> String

    static func staticFunction() -> String
}

// MARK: - The Stub

private class StubStringService: StringService, Stubbable {
    enum StaticFunction: String, StringRepresentable {
        case staticFunction = "staticFunction()"
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
        case takeAnOptionalString = "takeAnOptionalString(string:)"
        case callThisCompletion = "callThisCompletion(string:closure:)"
        case takeAnArrayOfSpryEquatable = "takeAnArrayOfSpryEquatable(array:)"
        case takeAnArrayOfNonSpryEquatable = "takeAnArrayOfNonSpryEquatable(array:)"
        case takeADictionaryOfSpryEquatable = "takeADictionaryOfSpryEquatable(dictionary:)"
        case takeADictionaryOfNonSpryEquatable = "takeADictionaryOfNonSpryEquatable(dictionary:)"
        case takeAnEquatable = "takeAnEquatable(anEquatable:)"
        case takeAnAnyObject = "takeAnAnyObject(anAnyObject:)"
        case takeAnAnyObjectAndEquatable = "takeAnAnyObjectAndEquatable(anAnyObjectAndEquatable:)"
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

    func giveMeAStringWithFallbackValue() -> String {
        return stubbedValue(fallbackValue: "fallback value")
    }

    func giveMeAnOptional() -> String? {
        return stubbedValue()
    }

    func giveMeAString(string: String) -> String {
        return stubbedValue(arguments: string)
    }

    func takeAnOptionalString(string: String?) -> String {
        return stubbedValue(arguments: string)
    }

    func callThisCompletion(string: String, closure: () -> Void) {
        return stubbedValue(arguments: string, closure)
    }

    func takeAnArrayOfSpryEquatable(array: [Int]) -> String {
        return stubbedValue(arguments: array)
    }

    func takeAnArrayOfNonSpryEquatable(array: [MyNonSpryEquatableClass]) -> String {
        return stubbedValue(arguments: array)
    }

    func takeADictionaryOfSpryEquatable(dictionary: [String: Int]) -> String {
        return stubbedValue(arguments: dictionary)
    }

    func takeADictionaryOfNonSpryEquatable(dictionary: [String: MyNonSpryEquatableClass]) -> String {
        return stubbedValue(arguments: dictionary)
    }

    func takeAnEquatable(anEquatable: MyEquatable) -> String {
        return stubbedValue(arguments: anEquatable)
    }

    func takeAnAnyObject(anAnyObject: MyAnyObject) -> String {
        return stubbedValue(arguments: anAnyObject)
    }

    func takeAnAnyObjectAndEquatable(anAnyObjectAndEquatable: MyAnyObjectEquatable) -> String {
        return stubbedValue(arguments: anAnyObjectAndEquatable)
    }

    static func staticFunction() -> String {
        return stubbedValue()
    }
}

class StubbableSpec: QuickSpec {
    override func spec() {

        describe("Stubbable") {
            var subject: StubStringService!

            beforeEach {
                subject = StubStringService()
            }

            describe("and return") {
                describe("returning a simple value") {
                    let expectedString = "expected"

                    beforeEach {
                        subject.stub(.giveMeAString).andReturn(expectedString)
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.giveMeAString()).to(equal(expectedString))
                    }
                }

                describe("returning a tuple") {
                    beforeEach {
                        subject.stub(.hereComesATuple).andReturn(("hello", "world"))
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
                        subject.stub(.hereComesAProtocol).andReturn(expectedValue)
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
                        specialString.stub(.myStringValue).andReturn(expectedValue)

                        subject.stub(.hereComesAProtocol).andReturn(specialString)
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
                        secondHalfSpecialString.stub(.myStringValue).andReturn(expectedSecondHalf)

                        subject.stub(.hereComesProtocolsInATuple).andReturn((expectedFirstHalf, secondHalfSpecialString))
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
                        subject.stub(.hereComesProtocolWithSelfRequirements).andReturn(expectedMyClass)
                    }

                    it("should be able to stub a tuple of protocols as a return type") {
                        let actualMyClass = subject.hereComesProtocolWithSelfRequirements(object: MyClass())
                        expect(actualMyClass).to(beIdenticalTo(expectedMyClass))
                    }
                }

                describe("returning a closure") {
                    let expectedString = "string from closure"

                    beforeEach {
                        subject.stub(.hereComesAClosure).andReturn({ expectedString })
                    }

                    it("should get a closure from the stubbed service") {
                        let closure = subject.hereComesAClosure()
                        expect(closure()).to(equal(expectedString))
                    }
                }

                describe("returning an optional") {
                    context("when stubbed with an optional .some") {
                        let expectedReturn: String? = "i should be returned"

                        beforeEach {
                            subject.stub(.giveMeAnOptional).andReturn(expectedReturn)
                        }

                        it("should return the stubbed value") {
                            expect(subject.giveMeAnOptional()).to(equal(expectedReturn))
                        }
                    }

                    context("when stubbed with a NON-optional") {
                        let expectedReturn = "i should be returned"

                        beforeEach {
                            subject.stub(.giveMeAnOptional).andReturn(expectedReturn)
                        }

                        it("should return the stubbed value") {
                            expect(subject.giveMeAnOptional()).to(equal(expectedReturn))
                        }
                    }

                    context("when stubbed with nil") {
                        beforeEach {
                            subject.stub(.giveMeAnOptional).andReturn(nil as String?)
                        }

                        it("should return the stubbed value") {
                            expect(subject.giveMeAnOptional()).to(beNil())
                        }
                    }
                }
            }

            describe("and do") {
                context("when there are NO arguments") {
                    let expectedString = "expected"

                    beforeEach {
                        subject.stub(.giveMeAString).andDo { _ in
                            return expectedString
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.giveMeAString()).to(equal(expectedString))
                    }
                }

                describe("respecting passed in arguments and the return value") {
                    beforeEach {
                        subject.stub(.hereAreTwoStrings).andDo { arguments in
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
                        subject.stub(.callThisCompletion).andDo { arguments in
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
                            subject.stub(.callThisCompletion).with(expectedargument, Argument.anything).andDo { arguments in
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
                            subject.stub(.hereAreTwoStrings).with("what is needed", Argument.anything).andDo { _ in
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

            describe("stubbing a property") {
                let expectedString = "expected"

                beforeEach {
                    subject.stub(.myProperty).andReturn(expectedString)
                }

                it("should get a string from the stubbed service") {
                    expect(subject.myProperty).to(equal(expectedString))
                }
            }

            describe("stubbing a static function") {
                let expectedString = "expected"

                beforeEach {
                    StubStringService.stub(.staticFunction).andReturn(expectedString)
                }

                it("should get a string from the stubbed service") {
                    expect(StubStringService.staticFunction()).to(equal(expectedString))
                }
            }

            describe("passing in arguments") {
                context("when the arguments match what is stubbed") {
                    let expectedArg = "im expected"
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.giveMeAString_string).with(expectedArg).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAString(string: expectedArg)).to(equal(expectedReturn))
                    }
                }

                context("when the arguments do NOT match what is stubbed") {
                    beforeEach {
                        subject.stub(.giveMeAString_string).with("not expected").andReturn("return value")
                    }

                    it("should fatal error") {
                        expect({_ = subject.giveMeAString(string: "")}()).to(throwAssertion())
                    }
                }

                context("when there are no arguments passed in") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.giveMeAString_string).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAString(string: "doesn't matter")).to(equal(expectedReturn))
                    }
                }

                context("when the argument is Optional.none") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeAnOptionalString).with(nil as Any?).andReturn(expectedReturn)
                    }

                    it("should return the stubbed value") {
                        expect(subject.takeAnOptionalString(string: nil)).to(equal(expectedReturn))
                    }
                }

                context("when the argument is Equatable and is NOT AnyObject") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeAnEquatable).andReturn("I shouldn't win")
                        let argument = MyEquatable(string: "hello")
                        subject.stub(.takeAnEquatable).with(argument).andReturn(expectedReturn)
                    }

                    it("should NOT use the Equatable comparison for AnyObject") {
                        let argument = MyEquatable(string: "hello")
                        expect(subject.takeAnEquatable(anEquatable: argument)).to(equal(expectedReturn))
                    }
                }

                context("when the argument is NOT Equatable and is AnyObject") {
                    let expectedReturn = "i should be returned"
                    let argument = MyAnyObject()

                    beforeEach {
                        subject.stub(.takeAnAnyObject).andReturn("I shouldn't win")
                        subject.stub(.takeAnAnyObject).with(argument).andReturn(expectedReturn)
                    }

                    it("should NOT use the Equatable comparison for AnyObject") {
                        expect(subject.takeAnAnyObject(anAnyObject: argument)).to(equal(expectedReturn))
                    }
                }

                context("when the argument is Equatable and is AnyObject") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeAnAnyObjectAndEquatable).andReturn(expectedReturn)

                        let argument = MyAnyObjectEquatable(string: "hello")
                        subject.stub(.takeAnAnyObjectAndEquatable).with(argument).andReturn("I shouldn't win")
                    }

                    it("should NOT use the Equatable comparison for AnyObject") {
                        let argument = MyAnyObjectEquatable(string: "hello")
                        expect(subject.takeAnAnyObjectAndEquatable(anAnyObjectAndEquatable: argument)).to(equal(expectedReturn))
                    }
                }

                context("when the argument is an array of SpryEquatables") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeAnArrayOfSpryEquatable).with([1, 2, 3]).andReturn(expectedReturn)
                        subject.stub(.takeAnArrayOfSpryEquatable).andReturn("should not get this")
                    }

                    it("should return the stubbed value") {
                        expect(subject.takeAnArrayOfSpryEquatable(array: [1, 2, 3])).to(equal(expectedReturn))
                        expect(subject.takeAnArrayOfSpryEquatable(array: [1, 2, 11111])).toNot(equal(expectedReturn))
                        expect(subject.takeAnArrayOfSpryEquatable(array: [1, 3, 2])).toNot(equal(expectedReturn))
                        expect(subject.takeAnArrayOfSpryEquatable(array: [1, 2, 3, 4])).toNot(equal(expectedReturn))
                        expect(subject.takeAnArrayOfSpryEquatable(array: [1, 2])).toNot(equal(expectedReturn))
                    }
                }

                context("when the argument is an array of NON-SpryEquatables") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeAnArrayOfNonSpryEquatable).with([MyNonSpryEquatableClass()]).andReturn(expectedReturn)
                        subject.stub(.takeAnArrayOfNonSpryEquatable).andReturn("should not get this")
                    }

                    it("should fatal error") {
                        expect({ _ = subject.takeAnArrayOfNonSpryEquatable(array: [MyNonSpryEquatableClass()]) }()).to(throwAssertion())
                    }
                }

                context("when the argument is a dictionary of SpryEquatables") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeADictionaryOfSpryEquatable).with(["one": 1, "two": 2]).andReturn(expectedReturn)
                        subject.stub(.takeADictionaryOfSpryEquatable).andReturn("should not get this")
                    }

                    it("should return the stubbed value") {
                        expect(subject.takeADictionaryOfSpryEquatable(dictionary: ["one": 1, "two": 2])).to(equal(expectedReturn))
                        expect(subject.takeADictionaryOfSpryEquatable(dictionary: ["one": 1, "two": 2, "three": 3])).toNot(equal(expectedReturn))
                        expect(subject.takeADictionaryOfSpryEquatable(dictionary: ["one": 1])).toNot(equal(expectedReturn))
                        expect(subject.takeADictionaryOfSpryEquatable(dictionary: ["one": 2, "two": 1])).toNot(equal(expectedReturn))
                    }
                }

                context("when the argument is a dictionary of NON-SpryEquatables") {
                    let expectedReturn = "i should be returned"

                    beforeEach {
                        subject.stub(.takeADictionaryOfNonSpryEquatable).with(["one": MyNonSpryEquatableClass()]).andReturn(expectedReturn)
                        subject.stub(.takeADictionaryOfNonSpryEquatable).andReturn("should not get this")
                    }

                    it("should fatal error") {
                        expect({ _ = subject.takeADictionaryOfNonSpryEquatable(dictionary: ["one": MyNonSpryEquatableClass()]) }()).to(throwAssertion())
                    }
                }

                describe("Argument specifiers") {
                    context("when the specifier is .anything") {
                        let expectedReturn = "i should be returned"

                        beforeEach {
                            subject.stub(.giveMeAString_string).with(Argument.anything).andReturn(expectedReturn)
                        }

                        it("should return the stubbed value") {
                            expect(subject.giveMeAString(string: "any string should work")).to(equal(expectedReturn))
                        }
                    }

                    context("when the specifier is .nonNil") {
                        let expectedReturn = "i should be returned"

                        beforeEach {
                            subject.stub(.giveMeAString_string).with(Argument.nonNil).andReturn(expectedReturn)
                        }

                        it("should return the stubbed value") {
                            expect(subject.giveMeAString(string: "any string should work")).to(equal(expectedReturn))
                        }
                    }

                    context("when the specifier is .nil") {
                        let expectedReturn = "i should be returned"

                        beforeEach {
                            subject.stub(.takeAnOptionalString).with(Argument.nil).andReturn(expectedReturn)
                        }

                        it("should return the stubbed value") {
                            expect(subject.takeAnOptionalString(string: nil)).to(equal(expectedReturn))
                        }
                    }

                    context("when the specifier is .pass; passing validation") {
                        let actualArgument = "I'm the actual argument"
                        let expectedReturn = "i should be returned"

                        beforeEach {
                            let argumentValidation = Argument.pass({ actualArgument -> Bool in
                                let actualArgument = actualArgument as! String
                                expect(actualArgument).to(equal(actualArgument))

                                return true
                            })

                            subject.stub(.takeAnOptionalString).with(argumentValidation).andReturn(expectedReturn)
                            subject.stub(.takeAnOptionalString).andReturn("fallback")
                        }

                        it("should return the correct value for passing argument validation") {
                            expect(subject.takeAnOptionalString(string: actualArgument)).to(equal(expectedReturn))
                        }
                    }

                    context("when the specifier is .pass; passing validation") {
                        let actualArgument = "I'm the actual argument"
                        let expectedReturn = "i should be returned"

                        beforeEach {
                            let argumentValidation = Argument.pass({ actualArgument -> Bool in
                                let actualArgument = actualArgument as! String
                                expect(actualArgument).to(equal(actualArgument))

                                return false
                            })

                            subject.stub(.takeAnOptionalString).with(argumentValidation).andReturn("specific return value")
                            subject.stub(.takeAnOptionalString).andReturn(expectedReturn)
                        }

                        it("should return the correct value for failing argument validation") {
                            expect(subject.takeAnOptionalString(string: actualArgument)).to(equal(expectedReturn))
                        }
                    }
                }

                describe("Argument Capture") {
                    var argumentCapture: ArgumentCaptor!
                    let firstArg = "first arg"
                    let secondArg = "second arg"

                    beforeEach {
                        let correctSecondString = "correct second string"

                        argumentCapture = Argument.captor()
                        subject.stub(.hereAreTwoStrings).with(argumentCapture, correctSecondString).andReturn(true)
                        subject.stub(.hereAreTwoStrings).andReturn(true)

                        _ = subject.hereAreTwoStrings(string1: firstArg, string2: correctSecondString)
                        _ = subject.hereAreTwoStrings(string1: "shouldn't capture me", string2: "wrong argument")
                        _ = subject.hereAreTwoStrings(string1: secondArg, string2: correctSecondString)
                    }

                    it("should capture each argument when the stub passes validation (in order)") {
                        expect(argumentCapture.getValue(as: String.self)).to(equal(firstArg))
                        expect(argumentCapture.getValue(at: 1, as: String.self)).to(equal(secondArg))
                    }
                }
            }

            describe("fallback value") {
                context("when the function is stubbed with the appropriate type") {
                    let expectedString = "stubbed value"

                    beforeEach {
                        subject.stub(.giveMeAStringWithFallbackValue).andReturn(expectedString)
                    }

                    it("should return the stubbed value") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(equal(expectedString))
                    }
                }

                context("when the function is NOT stubbed with the appropriate type") {
                    beforeEach {
                        subject.stub(.giveMeAStringWithFallbackValue).andReturn(100)
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

            describe("improper stubbing without a fallback value") {
                context("when the value is not stubbed") {
                    it("should fatal error") {
                        expect({ _ = subject.giveMeAString() }()).to(throwAssertion())
                    }
                }

                context("when the value is stubbed with the wrong type") {
                    beforeEach {
                        subject.stub(.giveMeAString).andReturn(50)
                    }

                    it("should fatal error") {
                        expect({ _ = subject.giveMeAString() }()).to(throwAssertion())
                    }
                }
            }

            describe("resetting stubs on an instance") {
                context("when the function is stubbed before reseting") {
                    beforeEach {
                        subject.stub(.giveMeAString).andReturn("")
                        subject.resetStubs()
                    }

                    it("should NOT stub the function") {
                        expect({ _ = subject.giveMeAString() }()).to(throwAssertion())
                    }
                }

                context("when the function is stubbed after reseting") {
                    beforeEach {
                        subject.resetStubs()
                        subject.stub(.giveMeAString).andReturn("")
                    }

                    it("should stub the function") {
                        expect(subject.giveMeAString()).toNot(beNil())
                    }
                }
            }

            describe("resetting stubs on a class") {
                context("when the function is stubbed before reseting") {
                    beforeEach {
                        StubStringService.stub(.staticFunction).andReturn("")
                        StubStringService.resetStubs()
                    }

                    it("should NOT stub the function") {
                        expect({ _ = StubStringService.staticFunction() }()).to(throwAssertion())
                    }
                }

                context("when the function is stubbed after reseting") {
                    beforeEach {
                        StubStringService.resetStubs()
                        StubStringService.stub(.staticFunction).andReturn("")
                    }

                    it("should stub the function") {
                        expect(StubStringService.staticFunction()).toNot(beNil())
                    }
                }
            }
        }

    }
}
