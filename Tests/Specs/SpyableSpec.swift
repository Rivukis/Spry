import Quick
import Nimble
import NSpry

class SpyableSpec: QuickSpec {
    override func spec() {
        describe("Spyable") {
            var subject: SpyableTestHelper!

            beforeEach {
                subject = SpyableTestHelper()
            }

            afterEach {
                SpyableTestHelper.resetCalls()
            }

            describe("resetting calls") {
                describe("on an instance") {
                    beforeEach {
                        subject.doStuff()

                        subject.resetCalls()

                        subject.doStuffWith(string: "")
                    }

                    it("should forget all recorded calls before resetting") {
                        expect(subject.didCall(.doStuff).success).to(beFalse())

                        expect(subject.didCall(.doStuffWith).success).to(beTrue())
                    }
                }

                describe("on the class") {
                    beforeEach {
                        SpyableTestHelper.doClassStuff()

                        SpyableTestHelper.resetCalls()

                        SpyableTestHelper.doClassStuffWith(string: "")
                    }

                    it("should forget all recorded calls before resetting") {
                        expect(SpyableTestHelper.didCall(.doClassStuff).success).to(beFalse())

                        expect(SpyableTestHelper.didCall(.doClassStuffWith).success).to(beTrue())
                    }
                }
            }

            describe("did call - result.success") {
                describe("did set property") {
                    let newValue = "new value"

                    beforeEach {
                        subject.ivarProperty = newValue
                    }

                    it("should succeed for property being set") {
                        expect(subject.didCall(.ivarProperty).success).to(beTrue())
                        expect(subject.didCall(.ivarProperty, withArguments: [newValue]).success).to(beTrue())
                    }
                }

                describe("did call function; no arguments, no count specifier") {
                    beforeEach {
                        subject.doStuff()
                    }

                    it("should succeed for called functions") {
                        expect(subject.didCall(.doStuff).success).to(beTrue())
                    }

                    it("should NOT succeed for functions NOT called") {
                        expect(subject.didCall(.doStuffWith).success).to(beFalse())
                    }
                }

                describe("did call; no arguments; count specifier") {
                    let getSuccessValue: (CountSpecifier) -> Bool = { countSpecifier in
                        return subject.didCall(.doStuff, countSpecifier: countSpecifier).success
                    }

                    beforeEach {
                        subject.doStuff()
                        subject.doStuff()
                    }

                    describe(".exactly") {
                        it("should succeed when the number is == the called count") {
                            expect(getSuccessValue(.exactly(2))).to(beTrue())
                        }

                        it("should NOT succeed when the number is != the called count") {
                            expect(getSuccessValue(.exactly(1))).to(beFalse())
                            expect(getSuccessValue(.exactly(3))).to(beFalse())
                        }
                    }

                    describe(".atLeast") {
                        it("should succeed when the number is =< the called count") {
                            expect(getSuccessValue(.atLeast(1))).to(beTrue())
                            expect(getSuccessValue(.atLeast(2))).to(beTrue())
                        }

                        it("should NOT succeed when the number is > the called count") {
                            expect(getSuccessValue(.atLeast(3))).to(beFalse())
                        }
                    }

                    describe(".atMost") {
                        it("should succeed when the number is => the called count") {
                            expect(getSuccessValue(.atMost(2))).to(beTrue())
                            expect(getSuccessValue(.atMost(3))).to(beTrue())
                        }

                        it("should NOT succeed when the number is < the called count") {
                            expect(getSuccessValue(.atMost(1))).to(beFalse())
                        }
                    }
                }

                describe("did call function; with arguments, no count specifier") {
                    context("when the arguments match what is specified") {
                        let actualString = "actual string"

                        beforeEach {
                            subject.doStuffWith(string: actualString)
                        }

                        it("should succeed") {
                            let success = subject.didCall(.doStuffWith, withArguments: [actualString]).success
                            expect(success).to(beTrue())
                        }
                    }

                    context("when the arguments do NOT match what is specified") {
                        beforeEach {
                            subject.doStuffWith(string: "actual string")
                        }

                        it("should fail") {
                            let success = subject.didCall(.doStuffWith, withArguments: ["wrong string"]).success
                            expect(success).to(beFalse())
                        }
                    }
                }

                describe("did call; with arguments; count specifier") {
                    let actualString = "correct string"

                    let getSuccessValue: (CountSpecifier) -> Bool = { countSpecifier in
                        return subject.didCall(.doStuffWith, withArguments: [actualString], countSpecifier: countSpecifier).success
                    }

                    beforeEach {
                        subject.doStuffWith(string: actualString)
                        subject.doStuffWith(string: "wrong string")
                        subject.doStuffWith(string: actualString)
                    }

                    describe(".exactly") {
                        it("should succeed when the number is == the called count for the specified arg") {
                            expect(getSuccessValue(.exactly(2))).to(beTrue())
                        }

                        it("should NOT succeed when the number is != the called count for the specified arg") {
                            expect(getSuccessValue(.exactly(1))).to(beFalse())
                            expect(getSuccessValue(.exactly(3))).to(beFalse())
                        }
                    }

                    describe(".atLeast") {
                        it("should succeed when the number is =< the called count for the specified arg") {
                            expect(getSuccessValue(.atLeast(1))).to(beTrue())
                            expect(getSuccessValue(.atLeast(2))).to(beTrue())
                        }

                        it("should NOT succeed when the number is > the called count for the specified arg") {
                            expect(getSuccessValue(.atLeast(3))).to(beFalse())
                        }
                    }

                    describe(".atMost") {
                        it("should succeed when the number is => the called count for the specified arg") {
                            expect(getSuccessValue(.atMost(2))).to(beTrue())
                            expect(getSuccessValue(.atMost(3))).to(beTrue())
                        }

                        it("should NOT succeed when the number is < the called count for the specified arg") {
                            expect(getSuccessValue(.atMost(1))).to(beFalse())
                        }
                    }
                }

                describe("did call class function") {
                    let actualArgument = "correct string"

                    beforeEach {
                        SpyableTestHelper.doClassStuffWith(string: actualArgument)
                    }

                    it("should succeed for same reasons as an instance's did call") {
                        let nothingSpecifiedSuccess = SpyableTestHelper.didCall(.doClassStuffWith).success
                        expect(nothingSpecifiedSuccess).to(beTrue())

                        let argsSpecifiedSuccess = SpyableTestHelper.didCall(.doClassStuffWith, withArguments: [actualArgument]).success
                        expect(argsSpecifiedSuccess).to(beTrue())

                        let countSpecifiedSuccess = SpyableTestHelper.didCall(.doClassStuffWith, countSpecifier: .exactly(1)).success
                        expect(countSpecifiedSuccess).to(beTrue())

                        let allThingsSpecifiedSuccess = SpyableTestHelper.didCall(.doClassStuffWith, withArguments: [actualArgument], countSpecifier: .exactly(1)).success
                        expect(allThingsSpecifiedSuccess).to(beTrue())

                        let wrongFunctionSuccess = SpyableTestHelper.didCall(.doClassStuff).success
                        expect(wrongFunctionSuccess).to(beFalse())
                    }
                }
            }

            describe("did call - result.recordedCallsDescription") {
                describe("no calls") {
                    it("should show empty call list") {
                        let description = subject.didCall(.doStuff).recordedCallsDescription
                        expect(description).to(equal("<>"))
                    }
                }

                describe("single call with NO arguments") {
                    beforeEach {
                        subject.doStuff()
                    }

                    it("should show the function name") {
                        let description = subject.didCall(.doStuff).recordedCallsDescription
                        let functionName = SpyableTestHelper.Function.doStuff.rawValue
                        expect(description).to(equal("<\(functionName)>"))
                    }
                }

                describe("single call with arguments") {
                    let firstArg = 1
                    let secondArg = 2

                    beforeEach {
                        subject.doStuffWithWith(int1: firstArg, int2: secondArg)
                    }

                    it("should show the function name") {
                        let description = subject.didCall(.doStuff).recordedCallsDescription
                        let functionName = SpyableTestHelper.Function.doStuffWithWith.rawValue
                        let expectedDescription = "<\(functionName)> with <\(firstArg)>, <\(secondArg)>"
                        expect(description).to(equal(expectedDescription))
                    }
                }

                describe("multiple calls") {
                    let secondCallFirstArg = 1
                    let secondCallSecondArg = 2

                    beforeEach {
                        subject.doStuff()
                        subject.doStuffWithWith(int1: secondCallFirstArg, int2: secondCallSecondArg)
                    }

                    it("should show the function name") {
                        let description = subject.didCall(.doStuff).recordedCallsDescription
                        let firstFunctionName = SpyableTestHelper.Function.doStuff.rawValue
                        let secondFunctionName = SpyableTestHelper.Function.doStuffWithWith.rawValue

                        let expectedDescription = "<\(firstFunctionName)>; <\(secondFunctionName)> with <\(secondCallFirstArg)>, <\(secondCallSecondArg)>"
                        expect(description).to(equal(expectedDescription))
                    }
                }
            }
        }

    }
}
