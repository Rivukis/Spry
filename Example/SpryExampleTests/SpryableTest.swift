//
//  SpyableTest.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 7/2/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Quick
import Nimble
import SpryExample

private class SpryStringService: Spryable {
    enum Function: String, StringRepresentable {
        case getAString = "getAString()"
    }

    func getAString() -> String {
        return spryify()
    }
}

class SpryableSpec: QuickSpec {
    override func spec() {

        describe("Spryable") {
            var subject: SpryStringService!

            beforeEach {
                subject = SpryStringService()
            }

            describe("recording calls") {
                beforeEach {
                    subject.stub(.getAString).andReturn("")

                    _ = subject.getAString()
                }

                it("should have recorded the call using Spyable") {
                    let result = subject.didCall(.getAString)
                    expect(result.success).to(beTrue())
                }
            }

            describe("stubbing functions") {
                let expectedString = "stubbed string"

                beforeEach {
                    subject.stub(.getAString).andReturn(expectedString)
                }

                it("should return the stubbed value using Stubbable") {
                    expect(subject.getAString()).to(equal(expectedString))
                }
            }

            describe("reseting calls and stubs") {
                beforeEach {
                    subject.stub(.getAString).andReturn("")
                    _ = subject.getAString()

                    subject.resetCallsAndStubs()
                }

                it("should reset the calls and the stubs") {
                    expect(subject.didCall(.getAString).success).to(beFalse())
                    expect({ _ = subject.getAString() }()).to(throwAssertion())
                }
            }
        }
    }
}
