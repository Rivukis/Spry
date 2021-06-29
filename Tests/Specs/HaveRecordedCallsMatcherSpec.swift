import Quick
import Nimble

import NSpry

class HaveRecordedCallsMatcherSpec: QuickSpec {
    override func spec() {
        describe("HaveRecordedCallsMatcher") {
            var subject: SpyableTestHelper!

            beforeEach {
                subject = SpyableTestHelper()
            }

            describe("have recorded calls success result") {
                context("when at least one call has been made") {
                    beforeEach {
                        subject.doStuff()
                    }

                    it("should fail") {
                        expect(subject).to(haveRecordedCalls())
                    }
                }

                context("when no calls have been made") {
                    it("should succeed") {
                        expect(subject).toNot(haveRecordedCalls())
                    }
                }

                context("when reset calls has been called after calls have been made") {
                    beforeEach {
                        subject.doStuff()
                        subject.resetCalls()
                    }

                    it("should succeed") {
                        expect(subject).toNot(haveRecordedCalls())
                    }
                }
            }

            describe("failure message") {
                describe("nil Spyable") {
                    it("should be nil message") {
                        let expectedFailureMessage = "expected to have recorded calls, got <nil> (use beNil() to match nils)"

                        failsWithErrorMessage(expectedFailureMessage) {
                            expect(nil as SpyableTestHelper?).to(haveRecordedCalls())
                        }
                    }
                }

                describe("not nil description") {
                    it("should include the recorded calls description in the 'got' part of the message") {
                        let expectedFailureMessage = "expected to have recorded calls, got 0 calls"

                        failsWithErrorMessage(expectedFailureMessage) {
                            expect(subject).to(haveRecordedCalls())
                        }
                    }
                }
            }

            describe("class function spot check") {
                it("should be usable on class object") {
                    expect(SpyableTestHelper.self).toNot(haveRecordedCalls())
                }
            }
        }

    }
}
