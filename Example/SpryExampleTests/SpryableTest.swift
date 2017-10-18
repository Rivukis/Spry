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

private class SpryableTestClass: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case getAStaticString = "getAStaticString()"
    }

    static func getAStaticString() -> String {
        return spryify()
    }

    enum Function: String, StringRepresentable {
        case firstName
        case getAString = "getAString(string:)"
    }

    var firstName: String {
        set {
            recordCall(arguments: newValue)
        }
        get {
            return stubbedValue()
        }
    }

    func getAString(string: String) -> String {
        return spryify(arguments: string)
    }
}

class SpryableSpec: QuickSpec {
    override func spec() {

        describe("Spryable") {
            var subject: SpryableTestClass!

            beforeEach {
                subject = SpryableTestClass()
            }

            afterEach {
                SpryableTestClass.resetCallsAndStubs()
            }

            describe("recording calls - instance") {
                beforeEach {
                    subject.stub(.getAString).andReturn("")

                    _ = subject.getAString(string: "")
                }

                it("should have recorded the call using Spyable") {
                    let result = subject.didCall(.getAString)
                    expect(result.success).to(beTrue())
                }
            }

            describe("recording calls - static") {
                beforeEach {
                    SpryableTestClass.stub(.getAStaticString).andReturn("")

                    _ = SpryableTestClass.getAStaticString()
                }

                it("should have recorded the call using Spyable") {
                    let result = SpryableTestClass.didCall(.getAStaticString)
                    expect(result.success).to(beTrue())
                }
            }

            describe("stubbing functions - instance") {
                let expectedString = "stubbed string"

                beforeEach {
                    subject.stub(.getAString).andReturn(expectedString)
                }

                it("should return the stubbed value using Stubbable") {
                    expect(subject.getAString(string: "")).to(equal(expectedString))
                }
            }

            describe("stubbing functions - static") {
                let expectedString = "stubbed string"

                beforeEach {
                    SpryableTestClass.stub(.getAStaticString).andReturn(expectedString)
                }

                it("should return the stubbed value using Stubbable") {
                    expect(SpryableTestClass.getAStaticString()).to(equal(expectedString))
                }
            }

            describe("reseting calls and stubs") {
                beforeEach {
                    subject.stub(.getAString).andReturn("")
                    _ = subject.getAString(string: "")

                    subject.resetCallsAndStubs()
                }

                it("should reset the calls and the stubs") {
                    expect(subject.didCall(.getAString).success).to(beFalse())
                    expect({ _ = subject.getAString(string: "") }()).to(throwAssertion())
                }
            }

            describe("reseting calls and stubs") {
                beforeEach {
                    SpryableTestClass.stub(.getAStaticString).andReturn("")
                    _ = SpryableTestClass.getAStaticString()

                    SpryableTestClass.resetCallsAndStubs()
                }

                it("should reset the calls and the stubs") {
                    expect(SpryableTestClass.didCall(.getAStaticString).success).to(beFalse())
                    expect({ _ = SpryableTestClass.getAStaticString() }()).to(throwAssertion())
                }
            }
        }
    }
}
