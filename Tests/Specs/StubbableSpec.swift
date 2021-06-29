import Quick
import Nimble
import NSpry

class StubbableSpec: QuickSpec {
    override func spec() {
        describe("Stubbable") {
            var subject: StubbableTestHelper!

            beforeEach {
                subject = StubbableTestHelper()
            }

            afterEach {
                StubbableTestHelper.resetStubs()
            }

            describe("and return") {
                describe("default return value") {
                    beforeEach {
                        subject.stub(.giveMeAVoid).andReturn()
                    }

                    it("should default to Void()") {
                        expect(subject.giveMeAVoid()).to(beVoid())
                    }
                }

                describe("returning Void") {
                    beforeEach {
                        subject.stub(.giveMeAVoid).andReturn(())
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.giveMeAVoid()).to(beVoid())
                    }
                }

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
                    let expectedMyClass = ProtocolWithSelfRequirementImplemented()

                    beforeEach {
                        subject.stub(.hereComesProtocolWithSelfRequirements).andReturn(expectedMyClass)
                    }

                    it("should be able to stub a tuple of protocols as a return type") {
                        let actualMyClass = subject.hereComesProtocolWithSelfRequirements(object: ProtocolWithSelfRequirementImplemented())
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

                context("when there is ONE unnamed argument") {
                    let expectedString = "expected"

                    beforeEach {
                        subject.stub(.takeUnnamedArgument).andDo { arguments in
                            let string = arguments[0] as! String
                            return string == expectedString
                        }
                    }

                    it("should get a string from the stubbed service") {
                        expect(subject.takeUnnamedArgument(expectedString)).to(beTrue())
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
            }

            describe("and throw") {
                describe("functions that can throw") {
                    let stubbedError = StubbableError(id: "my error")

                    beforeEach {
                        subject.stub(.throwingFunction).andThrow(stubbedError)
                    }

                    it("should throw the specified error") {
                        expect({ try subject.throwingFunction() }).to(throwError(stubbedError))
                    }
                }

                describe("functions that can't throw") {
                    beforeEach {
                        subject.stub(.giveMeAString).andThrow(StubbableError(id: ""))
                    }

                    it("should fatal error") {
                        expect{
                            _ = subject.giveMeAString()
                        }.to(throwAssertion())
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

            describe("stubbing a class function") {
                let expectedString = "expected"

                beforeEach {
                    StubbableTestHelper.stub(.classFunction).andReturn(expectedString)
                }

                it("should get a string from the stubbed service") {
                    expect(StubbableTestHelper.classFunction()).to(equal(expectedString))
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

                describe("Argument Capture") {
                    var argumentCaptor: ArgumentCaptor!
                    let firstArg = "first arg"
                    let secondArg = "second arg"

                    beforeEach {
                        let correctSecondString = "correct second string"

                        argumentCaptor = Argument.captor()
                        subject.stub(.hereAreTwoStrings).with(argumentCaptor, correctSecondString).andReturn(true)
                        subject.stub(.hereAreTwoStrings).andReturn(true)

                        _ = subject.hereAreTwoStrings(string1: firstArg, string2: correctSecondString)
                        _ = subject.hereAreTwoStrings(string1: "shouldn't capture me", string2: "wrong argument")
                        _ = subject.hereAreTwoStrings(string1: secondArg, string2: correctSecondString)
                    }

                    it("should capture each argument when the stub passes validation (in order)") {
                        expect(argumentCaptor.getValue(as: String.self)).to(equal(firstArg))
                        expect(argumentCaptor.getValue(at: 1, as: String.self)).to(equal(secondArg))
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
                    let fallbackValue = "fallback value"

                    beforeEach {
                        subject.fallbackValueForgiveMeAStringWithFallbackValue = fallbackValue
                        subject.stub(.giveMeAStringWithFallbackValue).andReturn(100)
                    }

                    it("should return the fallback value") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(equal(fallbackValue))
                    }
                }

                context("when the function is NOT stubbed") {
                    let fallbackValue = "fallback value"

                    beforeEach {
                        subject.fallbackValueForgiveMeAStringWithFallbackValue = fallbackValue
                    }

                    it("should return the fallback value") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(equal("fallback value"))
                    }
                }

                context("when the fallback value is nil") {
                    beforeEach {
                        subject.fallbackValueForgiveMeAStringWithFallbackValue = nil
                    }

                    it("should return nil when the fallback value should be used") {
                        expect(subject.giveMeAStringWithFallbackValue()).to(beNil())
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

            describe("resetting stubs") {
                describe("on an instance") {
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

                describe("on a class") {
                    context("when the function is stubbed before reseting") {
                        beforeEach {
                            StubbableTestHelper.stub(.classFunction).andReturn("")
                            StubbableTestHelper.resetStubs()
                        }

                        it("should NOT stub the function") {
                            expect({ _ = StubbableTestHelper.classFunction() }()).to(throwAssertion())
                        }
                    }

                    context("when the function is stubbed after reseting") {
                        beforeEach {
                            StubbableTestHelper.resetStubs()
                            StubbableTestHelper.stub(.classFunction).andReturn("")
                        }

                        it("should stub the function") {
                            expect(StubbableTestHelper.classFunction()).toNot(beNil())
                        }
                    }
                }
            }

            describe("stubbing again") {
                describe("using .with()") {
                    let originalString = "original string"

                    beforeEach {
                        subject.stub(.giveMeAString_string).with(originalString).andReturn("original return value")
                    }

                    context("when same function; different parameters") {
                        it("should NOT fatal error") {
                            expect {
                                subject.stub(.giveMeAString_string).with("different string").andReturn("")
                            }.toNot(throwAssertion())
                        }
                    }

                    context("when same function; same parameters; using .stub") {
                        it("should fatal error") {
                            expect {
                                subject.stub(.giveMeAString_string).with(originalString).andReturn("")
                            }.to(throwAssertion())
                        }
                    }

                    context("when same function; same parameters; using .stubAgain") {
                        let newReturnValue = "new return value"

                        beforeEach {
                            subject.stubAgain(.giveMeAString_string).with(originalString).andReturn(newReturnValue)
                        }

                        it("should return the new return value") {
                            expect(subject.giveMeAString(string: originalString)).to(equal(newReturnValue))
                        }
                    }
                }

                describe("without .with()") {
                    beforeEach {
                        subject.stub(.giveMeAString_string).andReturn("original return value")
                    }

                    context("when same function; using .stub") {
                        it("should fatal error") {
                            expect {
                                subject.stub(.giveMeAString_string).andReturn("")
                            }.to(throwAssertion())
                        }
                    }

                    context("when same function; using .stubAgain") {
                        let newReturnValue = "new return value"

                        beforeEach {
                            subject.stubAgain(.giveMeAString_string).andReturn(newReturnValue)
                        }

                        it("should return the new return value") {
                            expect(subject.giveMeAString(string: "blah")).to(equal(newReturnValue))
                        }
                    }
                }

                describe("class version spot check") {
                    beforeEach {
                        StubbableTestHelper.stub(.classFunction).andReturn("original return value")
                    }

                    context("when same function; using .stub") {
                        it("should fatal error") {
                            expect {
                                StubbableTestHelper.stub(.classFunction).andReturn("")
                            }.to(throwAssertion())
                        }
                    }

                    context("when same function; using .stubAgain") {
                        let newReturnValue = "new return value"

                        beforeEach {
                            StubbableTestHelper.stubAgain(.classFunction).andReturn(newReturnValue)
                        }

                        it("should return the new return value") {
                            expect(StubbableTestHelper.classFunction()).to(equal(newReturnValue))
                        }
                    }
                }
            }
        }

    }
}
