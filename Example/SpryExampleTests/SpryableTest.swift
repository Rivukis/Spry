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
    enum StaticFunction: String, StringRepresentable {
        case getAStaticString = "getAStaticString()"
    }

    static func getAStaticString() -> String {
        return spryify()
    }

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

            afterEach {
                SpryStringService.resetCallsAndStubs()
            }

            describe("recording calls - instance") {
                beforeEach {
                    subject.stub(.getAString).andReturn("")

                    _ = subject.getAString()
                }

                it("should have recorded the call using Spyable") {
                    let result = subject.didCall(.getAString)
                    expect(result.success).to(beTrue())
                }
            }

            describe("recording calls - static") {
                beforeEach {
                    SpryStringService.stub(.getAStaticString).andReturn("")

                    _ = SpryStringService.getAStaticString()
                }

                it("should have recorded the call using Spyable") {
                    let result = SpryStringService.didCall(.getAStaticString)
                    expect(result.success).to(beTrue())
                }
            }

            describe("stubbing functions - instance") {
                let expectedString = "stubbed string"

                beforeEach {
                    subject.stub(.getAString).andReturn(expectedString)
                }

                it("should return the stubbed value using Stubbable") {
                    expect(subject.getAString()).to(equal(expectedString))
                }
            }

            describe("stubbing functions - static") {
                let expectedString = "stubbed string"

                beforeEach {
                    SpryStringService.stub(.getAStaticString).andReturn(expectedString)
                }

                it("should return the stubbed value using Stubbable") {
                    expect(SpryStringService.getAStaticString()).to(equal(expectedString))
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

            describe("reseting calls and stubs") {
                beforeEach {
                    SpryStringService.stub(.getAStaticString).andReturn("")
                    _ = SpryStringService.getAStaticString()

                    SpryStringService.resetCallsAndStubs()
                }

                it("should reset the calls and the stubs") {
                    expect(SpryStringService.didCall(.getAStaticString).success).to(beFalse())
                    expect({ _ = SpryStringService.getAStaticString() }()).to(throwAssertion())
                }
            }
        }
    }
}
