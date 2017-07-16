//
//  HaveReceivedMatcher.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/14/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import XCTest
import Quick
import SpryExample

@testable import Nimble

class HaveReceivedMatcherTest: XCTestCase {
    class TestClass: Spyable {
        enum Function: String, StringRepresentable {
            case doStuff = "doStuff()"
            case doStuffWith = "doStuffWith(string:)"
            case doThingsWith = "doThingsWith(string:int:)"
        }

        func doStuff() {
            self.recordCall()
        }

        func doStuffWith(string: String) {
            self.recordCall(arguments: string)
        }

        func doThingsWith(string: String, int: Int) {
            self.recordCall(arguments: string, int)
        }
    }

    func testCall() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuff()

        // THEN
        expect(testClass).to(haveReceived(.doStuff))
        expect(testClass).toNot(haveReceived(.doThingsWith))
    }

    func testCallFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuffWith(string: "swift")

        // WHEN
        let toFailingTest = { expect(testClass).to(haveReceived(.doStuff)) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuffWith)) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuff)) }

        // THEN
        let toExpectedMessage = "expected to receive <doStuff()> on <TestClass>, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not receive <doStuffWith(string:)> on <TestClass>, got <doStuffWith(string:) with swift>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithCount() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "string")

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, countSpecifier: .exactly(1)))
        expect(testClass).toNot(haveReceived(.doStuffWith, countSpecifier: .exactly(2)))
    }

    func testCallWithCountFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuff()

        // WHEN
        let toFailingTest1 = { expect(testClass).to(haveReceived(.doStuffWith, countSpecifier: .exactly(1))) }
        let toFailingTest2 = { expect(testClass).to(haveReceived(.doStuff, countSpecifier: .exactly(2))) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuff, countSpecifier: .exactly(1))) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuff, countSpecifier: .exactly(1))) }

        // THEN
        let toExpectedMessage1 = "expected to receive <doStuffWith(string:)> on <TestClass> exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to receive <doStuff()> on <TestClass> exactly 2 times, got <doStuff()>"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not receive <doStuff()> on <TestClass> exactly 1 time, got <doStuff()>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function 'count' times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithAtLeast() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "string")

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, countSpecifier: .atLeast(1)))
        expect(testClass).toNot(haveReceived(.doStuffWith, countSpecifier: .atLeast(2)))
    }

    func testCallWithAtLeastFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doStuff()

        // WHEN
        let toFailingTest = { expect(testClass).to(haveReceived(.doStuff, countSpecifier: .atLeast(3))) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuff, countSpecifier: .atLeast(2))) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuff, countSpecifier: .atLeast(2))) }

        // THEN
        let toExpectedMessage = "expected to receive <doStuff()> on <TestClass> at least 3 times, got <doStuff()>, <doStuff()>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not receive <doStuff()> on <TestClass> at least 2 times, got <doStuff()>, <doStuff()>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function at least 'count' times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithAtMost() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "string")

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, countSpecifier: .atMost(1)))
        expect(testClass).toNot(haveReceived(.doStuffWith, countSpecifier: .atMost(0)))
    }

    func testCallWithAtMostFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // WHEN
        let toFailingTest1 = { expect(testClass).to(haveReceived(.doStuffWith, countSpecifier: .atMost(1))) }
        let toFailingTest2 = { expect(testClass).to(haveReceived(.doStuff, countSpecifier: .atMost(2))) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuff, countSpecifier: .atMost(4))) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuff, countSpecifier: .atMost(1))) }

        // THEN
        let got = "got <doStuff()>, <doStuff()>, <doStuff()>, <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"
        let toExpectedMessage1 = "expected to receive <doStuffWith(string:)> on <TestClass> at most 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to receive <doStuff()> on <TestClass> at most 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not receive <doStuff()> on <TestClass> at most 4 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function at most 'count' times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArguments() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "quick")
        testClass.doThingsWith(string: "nimble", int: 5)

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, with: "quick"))
        expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble"))
        expect(testClass).to(haveReceived(.doThingsWith, with: "nimble", 5))
        expect(testClass).toNot(haveReceived(.doThingsWith, with: "nimble", 10))
    }

    func testCallWithArgumentsFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuffWith(string: "nimble")

        // WHEN
        let toFailingTest = { expect(testClass).to(haveReceived(.doStuffWith, with: "quick")) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble")) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuffWith, with: "call matcher")) }

        // THEN
        let toExpectedMessage = "expected to receive <doStuffWith(string:)> on <TestClass> with <quick>, got <doStuffWith(string:) with nimble>"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not receive <doStuffWith(string:)> on <TestClass> with <nimble>, got <doStuffWith(string:) with nimble>"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function with arguments, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArgumentsAndCount() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        testClass.doThingsWith(string: "nimble", int: 5)

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .exactly(1)))
        expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .exactly(2)))
        expect(testClass).to(haveReceived(.doThingsWith, with: "nimble", 5, countSpecifier: .exactly(1)))
        expect(testClass).toNot(haveReceived(.doThingsWith, with: "nimble", 5, countSpecifier: .exactly(2)))
    }

    func testCallWithArgumentsAndCountFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // WHEN
        let toFailingTest1 = { expect(testClass).to(haveReceived(.doStuff, with: "swift", countSpecifier: .exactly(1))) }
        let toFailingTest2 = { expect(testClass).to(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .exactly(2))) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .exactly(1))) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuffWith, with: "call matcher", countSpecifier: .exactly(1))) }

        // THEN
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>"

        let toExpectedMessage1 = "expected to receive <doStuff()> on <TestClass> with <swift> exactly 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to receive <doStuffWith(string:)> on <TestClass> with <nimble> exactly 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not receive <doStuffWith(string:)> on <TestClass> with <nimble> exactly 1 time, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function with arguments 'count' times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArgumentsAndAtLeast() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .atLeast(1)))
        expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .atLeast(2)))
    }

    func testCallWithArgumentsAndAtLeastFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")
        testClass.doStuffWith(string: "nimble")

        // WHEN
        let toFailingTest = { expect(testClass).to(haveReceived(.doStuff, with: "quick", countSpecifier: .atLeast(2))) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .atLeast(2))) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuffWith, with: "call matcher", countSpecifier: .atLeast(2))) }

        // THEN
        let got = "got <doStuffWith(string:) with quick>, <doStuffWith(string:) with nimble>, <doStuffWith(string:) with nimble>"

        let toExpectedMessage = "expected to receive <doStuff()> on <TestClass> with <quick> at least 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage) { toFailingTest() }

        let toNotExpectedMessage = "expected to not receive <doStuffWith(string:)> on <TestClass> with <nimble> at least 2 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function with arguments at least 'count' times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }

    func testCallWithArgumentsAndAtMost() {
        // GIVEN
        let testClass = TestClass()

        // WHEN
        testClass.doStuffWith(string: "quick")
        testClass.doStuffWith(string: "nimble")

        // THEN
        expect(testClass).to(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .atMost(1)))
        expect(testClass).toNot(haveReceived(.doStuffWith, with: "nimble", countSpecifier: .atMost(0)))
    }

    func testCallWithArgumentsAndAtMostFailureMessage() {
        // GIVEN
        let testClass = TestClass()
        testClass.doThingsWith(string: "call matcher", int: 5)
        testClass.doThingsWith(string: "call matcher", int: 5)
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")
        testClass.doStuffWith(string: "swift")

        // WHEN
        let toFailingTest1 = { expect(testClass).to(haveReceived(.doThingsWith, with: "call matcher", 5, countSpecifier: .atMost(1))) }
        let toFailingTest2 = { expect(testClass).to(haveReceived(.doStuffWith, with: "swift", countSpecifier: .atMost(2))) }
        let toNotFailingTest = { expect(testClass).toNot(haveReceived(.doStuffWith, with: "swift", countSpecifier: .atMost(4))) }
        let nilFailingTest = { expect(nil as TestClass?).to(haveReceived(.doStuffWith, with: "swift", countSpecifier: .atMost(1))) }

        // THEN
        let got = "got <doThingsWith(string:int:) with call matcher, 5>, <doThingsWith(string:int:) with call matcher, 5>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>, <doStuffWith(string:) with swift>"

        let toExpectedMessage1 = "expected to receive <doThingsWith(string:int:)> on <TestClass> with <call matcher>, <5> at most 1 time, \(got)"
        failsWithErrorMessage(toExpectedMessage1) { toFailingTest1() }

        let toExpectedMessage2 = "expected to receive <doStuffWith(string:)> on <TestClass> with <swift> at most 2 times, \(got)"
        failsWithErrorMessage(toExpectedMessage2) { toFailingTest2() }

        let toNotExpectedMessage = "expected to not receive <doStuffWith(string:)> on <TestClass> with <swift> at most 4 times, \(got)"
        failsWithErrorMessage(toNotExpectedMessage) { toNotFailingTest() }

        let nilExpectedMessage = "expected to receive function with arguments at most 'count' times, got <nil>"
        failsWithErrorMessageForNil(nilExpectedMessage) { nilFailingTest() }
    }
}
