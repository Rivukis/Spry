import Quick
import Nimble

import NSpry

class HaveReceivedMatcherSpec: QuickSpec {
    override func spec() {
        describe("HaveReceivedMatcher") {
            var subject: SpyableTestHelper!

            beforeEach {
                subject = SpyableTestHelper()
            }

            describe("have received success result") {
                describe("instance function") {
                    let actualArgument = "correct arg"

                    beforeEach {
                        subject.doStuffWith(string: actualArgument)
                    }

                    it("should use did call to determine test result") {
                        expect(subject).to(haveReceived(.doStuffWith))
                        expect(subject).to(haveReceived(.doStuffWith, with: actualArgument))
                        expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .exactly(1)))
                        expect(subject).to(haveReceived(.doStuffWith, with: actualArgument, countSpecifier: .exactly(1)))

                        expect(subject).toNot(haveReceived(.doStuff))
                    }
                }

                describe("class function") {
                    let actualArgument = "correct class arg"

                    beforeEach {
                        SpyableTestHelper.doClassStuffWith(string: actualArgument)
                    }

                    afterEach {
                        SpyableTestHelper.resetCalls()
                    }

                    it("should use did call to determine test result") {
                        expect(SpyableTestHelper.self).to(haveReceived(.doClassStuffWith))
                        expect(SpyableTestHelper.self).to(haveReceived(.doClassStuffWith, with: actualArgument))
                        expect(SpyableTestHelper.self).to(haveReceived(.doClassStuffWith, countSpecifier: .exactly(1)))
                        expect(SpyableTestHelper.self).to(haveReceived(.doClassStuffWith, with: actualArgument, countSpecifier: .exactly(1)))

                        expect(SpyableTestHelper.self).toNot(haveReceived(.doClassStuff))
                    }
                }
            }

            describe("failure message") {
                describe("nil Spyable") {
                    it("should be nil message") {
                        let expectedFailureMessage = "expected to receive function, got <nil> (use beNil() to match nils)"

                        failsWithErrorMessage(expectedFailureMessage) {
                            expect(nil as SpyableTestHelper?).to(haveReceived(.doStuffWith))
                        }
                    }
                }

                describe("recorded calls description") {
                    beforeEach {
                        subject.doStuff()
                    }

                    it("should include the recorded calls description in the 'got' part of the message") {
                        let recordedCallsDescription = subject.didCall(.doStuffWith).recordedCallsDescription
                        let expectedFailureMessage = "expected to receive <doStuffWith(string:)> on <SpyableTestHelper>, got \(recordedCallsDescription)"

                        failsWithErrorMessage(expectedFailureMessage) {
                            expect(subject).to(haveReceived(.doStuffWith))
                        }
                    }
                }

                describe("expected function; no arguments; no count specifier") {
                    it("should include the function name and the class name") {
                        let functionName = SpyableTestHelper.Function.doStuffWith.rawValue
                        let expectedFailureMessage = "expected to receive <\(functionName)> on <\(SpyableTestHelper.self)>, got <>"

                        failsWithErrorMessage(expectedFailureMessage) {
                            expect(subject).to(haveReceived(.doStuffWith))
                        }
                    }
                }

                describe("expected function; no arguments; count specifier") {
                    let beginningPartOfMessage = "expected to receive <doStuffWith(string:)> on <SpyableTestHelper>"

                    describe(".exactly") {
                        let endingPartOfMessage = ", got <>"

                        it("should include the count specifier") {
                            let multipleSpecifiedCount = 5
                            let multipleCountSpecifierPart = " exactly \(multipleSpecifiedCount) times"
                            let expectedMultipleFailureMessage = beginningPartOfMessage + multipleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedMultipleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .exactly(multipleSpecifiedCount)))
                            }

                            let singleSpecifiedCount = 1
                            let singleCountSpecifierPart = " exactly \(singleSpecifiedCount) time"
                            let expectedSingleFailureMessage = beginningPartOfMessage + singleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedSingleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .exactly(singleSpecifiedCount)))
                            }
                        }
                    }

                    describe(".atLeast") {
                        let endingPartOfMessage = ", got <>"

                        context("when the count is '1'") {
                            it("should NOT include the count specifier") {
                                let expectedSingleFailureMessage = beginningPartOfMessage + endingPartOfMessage

                                failsWithErrorMessage(expectedSingleFailureMessage) {
                                    expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .atLeast(1)))
                                }
                            }
                        }

                        context("when the count is NOT '1'") {
                            it("should include the count specifier") {
                                let specifiedCount = 5
                                let countSpecifierPart = " at least \(specifiedCount) times"
                                let expectedFailureMessage = beginningPartOfMessage + countSpecifierPart + endingPartOfMessage

                                failsWithErrorMessage(expectedFailureMessage) {
                                    expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .atLeast(specifiedCount)))
                                }
                            }
                        }
                    }

                    describe(".atMost") {
                        let endingPartOfMessage = ", got <doStuffWith(string:)> with <1>; <doStuffWith(string:)> with <2>; <doStuffWith(string:)> with <3>"

                        beforeEach {
                            subject.doStuffWith(string: "1")
                            subject.doStuffWith(string: "2")
                            subject.doStuffWith(string: "3")
                        }

                        it("should include the count specifier") {
                            let multipleSpecifiedCount = 2
                            let multipleCountSpecifierPart = " at most \(multipleSpecifiedCount) times"
                            let expectedMultipleFailureMessage = beginningPartOfMessage + multipleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedMultipleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .atMost(multipleSpecifiedCount)))
                            }

                            let singleSpecifiedCount = 1
                            let singleCountSpecifierPart = " at most \(singleSpecifiedCount) time"
                            let expectedSingleFailureMessage = beginningPartOfMessage + singleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedSingleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, countSpecifier: .atMost(singleSpecifiedCount)))
                            }
                        }
                    }
                }

                describe("expected function; with arguments; no count specifier") {
                    let expectedFirstArg = 1
                    let expectedSecondArg = 2

                    it("should include comma separated arguments") {
                        let functionName = SpyableTestHelper.Function.doStuffWithWith.rawValue
                        let expectedFailureMessage = "expected to receive <\(functionName)> on <\(SpyableTestHelper.self)> with <\(expectedFirstArg)>, <\(expectedSecondArg)>, got <>"

                        failsWithErrorMessage(expectedFailureMessage) {
                            expect(subject).to(haveReceived(.doStuffWithWith, with: expectedFirstArg, expectedSecondArg))
                        }
                    }
                }

                describe("expected function; with arguments; count specifier") {
                    describe(".exactly") {
                        let specifiedArgument = "specified argument"
                        let beginningPartOfMessage = "expected to receive <doStuffWith(string:)> on <SpyableTestHelper> with <\(specifiedArgument)>"
                        let endingPartOfMessage = ", got <>"

                        it("should include the count specifier") {
                            let multipleSpecifiedCount = 5
                            let multipleCountSpecifierPart = " exactly \(multipleSpecifiedCount) times"
                            let expectedMultipleFailureMessage = beginningPartOfMessage + multipleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedMultipleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, with: specifiedArgument, countSpecifier: .exactly(multipleSpecifiedCount)))
                            }

                            let singleSpecifiedCount = 1
                            let singleCountSpecifierPart = " exactly \(singleSpecifiedCount) time"
                            let expectedSingleFailureMessage = beginningPartOfMessage + singleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedSingleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, with: specifiedArgument, countSpecifier: .exactly(singleSpecifiedCount)))
                            }
                        }
                    }

                    describe(".atLeast") {
                        let specifiedArgument = "specified argument"
                        let beginningPartOfMessage = "expected to receive <doStuffWith(string:)> on <SpyableTestHelper> with <\(specifiedArgument)>"
                        let endingPartOfMessage = ", got <>"

                        context("when the count is '1'") {
                            it("should NOT include the count specifier") {
                                let expectedSingleFailureMessage = beginningPartOfMessage + endingPartOfMessage

                                failsWithErrorMessage(expectedSingleFailureMessage) {
                                    expect(subject).to(haveReceived(.doStuffWith, with: specifiedArgument, countSpecifier: .atLeast(1)))
                                }
                            }
                        }

                        context("when the count is NOT '1'") {
                            it("should include the count specifier") {
                                let specifiedCount = 5
                                let countSpecifierPart = " at least \(specifiedCount) times"
                                let expectedFailureMessage = beginningPartOfMessage + countSpecifierPart + endingPartOfMessage

                                failsWithErrorMessage(expectedFailureMessage) {
                                    expect(subject).to(haveReceived(.doStuffWith, with: specifiedArgument, countSpecifier: .atLeast(specifiedCount)))
                                }
                            }
                        }
                    }

                    describe(".atMost") {
                        let specifiedArgument = "specified argument"
                        let beginningPartOfMessage = "expected to receive <doStuffWith(string:)> on <SpyableTestHelper> with <\(specifiedArgument)>"
                        let endingPartOfMessage = ", got <doStuffWith(string:)> with <\(specifiedArgument)>; <doStuffWith(string:)> with <\(specifiedArgument)>; <doStuffWith(string:)> with <\(specifiedArgument)>"

                        beforeEach {
                            subject.doStuffWith(string: specifiedArgument)
                            subject.doStuffWith(string: specifiedArgument)
                            subject.doStuffWith(string: specifiedArgument)
                        }

                        it("should include the count specifier") {
                            let multipleSpecifiedCount = 2
                            let multipleCountSpecifierPart = " at most \(multipleSpecifiedCount) times"
                            let expectedMultipleFailureMessage = beginningPartOfMessage + multipleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedMultipleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, with: specifiedArgument, countSpecifier: .atMost(multipleSpecifiedCount)))
                            }

                            let singleSpecifiedCount = 1
                            let singleCountSpecifierPart = " at most \(singleSpecifiedCount) time"
                            let expectedSingleFailureMessage = beginningPartOfMessage + singleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedSingleFailureMessage) {
                                expect(subject).to(haveReceived(.doStuffWith, with: specifiedArgument, countSpecifier: .atMost(singleSpecifiedCount)))
                            }
                        }
                    }

                    describe("class function") {
                        let specifiedArgument = "specified argument"
                        let beginningPartOfMessage = "expected to receive <doClassStuffWith(string:)> on <SpyableTestHelper> with <\(specifiedArgument)>"
                        let endingPartOfMessage = ", got <>"

                        it("should use same rules as instance function") {
                            let multipleSpecifiedCount = 5
                            let multipleCountSpecifierPart = " exactly \(multipleSpecifiedCount) times"
                            let expectedMultipleFailureMessage = beginningPartOfMessage + multipleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedMultipleFailureMessage) {
                                expect(SpyableTestHelper.self).to(haveReceived(.doClassStuffWith, with: specifiedArgument, countSpecifier: .exactly(multipleSpecifiedCount)))
                            }

                            let singleSpecifiedCount = 1
                            let singleCountSpecifierPart = " exactly \(singleSpecifiedCount) time"
                            let expectedSingleFailureMessage = beginningPartOfMessage + singleCountSpecifierPart + endingPartOfMessage

                            failsWithErrorMessage(expectedSingleFailureMessage) {
                                expect(SpyableTestHelper.self).to(haveReceived(.doClassStuffWith, with: specifiedArgument, countSpecifier: .exactly(singleSpecifiedCount)))
                            }
                        }
                    }
                }
            }
        }

    }
}
