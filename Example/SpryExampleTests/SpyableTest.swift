//
//  SpyableTest.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/1/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import XCTest
import SpryExample

private class TestClass: Spyable {
    enum Function: String, StringRepresentable {
        case ivarProperty
        case readOnlyProperty
        case doStuff = "doStuff()"
        case doStuffWith = "doStuffWith(string:)"
        case doMoreStuffWith = "doMoreStuffWith(int1:int2:)"
        case doWeirdStuffWith = "doWeirdStuffWith(string:int:)"
        case doCrazyStuffWith = "doCrazyStuffWith(object:)"
    }

    var ivarProperty: String = "" {
        didSet {
            recordCall(arguments: ivarProperty)
        }
    }

    var readOnlyProperty: String {
        set {
            recordCall(arguments: newValue)
        }
        get {
            return ""
        }
    }

    func doStuff() {
        recordCall()
    }

    func doStuffWith(string: String) {
        recordCall(arguments: string)
    }

    func doMoreStuffWith(int1: Int, int2: Int) {
        recordCall(arguments: int1, int2)
    }

    func doWeirdStuffWith(string: String?, int: Int?) {
        recordCall(arguments: string, int)
    }

    func doCrazyStuffWith(object: NSObject) {
        recordCall(arguments: object)
    }
}

class SpyableTest: XCTestCase {

    // MARK: - Resetting Calls

    func testResettingCalls() {
        // given
        let testClass = TestClass()
        testClass.doMoreStuffWith(int1: 0, int2: 0)

        // when
        testClass.resetCalls()
        testClass.doStuffWith(string: "")

        // then
        XCTAssertFalse(testClass.didCall(.doMoreStuffWith).success, "should FAIL to call function")
        XCTAssertTrue(testClass.didCall(.doStuffWith).success, "should SUCCEED to call function")
    }

    // MARK: - Did Call Tests

    func testDidCallIvarProperty() {
        // given
        let testClass = TestClass()

        // when
        testClass.ivarProperty = "new value"

        // then
        XCTAssertTrue(testClass.didCall(.ivarProperty).success, "should SUCCEED to set property")
        XCTAssertTrue(testClass.didCall(.ivarProperty, withArguments: ["new value"]).success, "should SUCCEED to set property with new value")
    }

    func testDidCallReadOnlyProperty() {
        // given
        let testClass = TestClass()

        // when
        testClass.readOnlyProperty = "new value"

        // then
        XCTAssertTrue(testClass.didCall(.readOnlyProperty).success, "should SUCCEED to set property")
        XCTAssertTrue(testClass.didCall(.readOnlyProperty, withArguments: ["new value"]).success, "should SUCCEED to set property with new value")
    }

    func testDidCallFunction() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuff()

        // then
        XCTAssertTrue(testClass.didCall(.doStuff).success, "should SUCCEED to call function")
        XCTAssertFalse(testClass.didCall(.doWeirdStuffWith).success, "should FAIL to call function")
    }

    func testDidCallFunctionANumberOfTimes() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuff()
        testClass.doStuff()

        // then
        XCTAssertTrue(testClass.didCall(.doStuff, countSpecifier: .exactly(2)).success, "should SUCCEED to call function 2 times")
        XCTAssertFalse(testClass.didCall(.doStuff, countSpecifier: .exactly(1)).success, "should FAIL to call the function 1 time")
        XCTAssertFalse(testClass.didCall(.doStuff, countSpecifier: .exactly(3)).success, "should FAIL to call the function 3 times")
    }

    func testDidCallFunctionAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuff()
        testClass.doStuff()

        // then
        XCTAssertTrue(testClass.didCall(.doStuff, countSpecifier: .atLeast(2)).success, "should SUCCEED to call function at least 2 times")
        XCTAssertTrue(testClass.didCall(.doStuff, countSpecifier: .atLeast(1)).success, "should SUCCEED to call function at least 1 time")
        XCTAssertFalse(testClass.didCall(.doStuff, countSpecifier: .atLeast(3)).success, "should FAIL to call function at least 3 times")
    }

    func testDidCallFunctionAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuff()
        testClass.doStuff()

        // then
        XCTAssertTrue(testClass.didCall(.doStuff, countSpecifier: .atMost(2)).success, "should SUCCEED to call function at most 2 times")
        XCTAssertTrue(testClass.didCall(.doStuff, countSpecifier: .atMost(3)).success, "should SUCCEED to call function at most 3 times")
        XCTAssertFalse(testClass.didCall(.doStuff, countSpecifier: .atMost(1)).success, "should FAIL to call function at most 1 time")
    }

    func testDidCallFunctionWithArguments() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "hi")

        // then
        XCTAssertTrue(testClass.didCall(.doStuffWith, withArguments: ["hi"]).success, "should SUCCEED to call correct function with correct arguments")
        XCTAssertFalse(testClass.didCall(.doStuffWith, withArguments: ["hello"]).success, "should FAIL to call correct function with wrong arguments")
        XCTAssertFalse(testClass.didCall(.doWeirdStuffWith, withArguments: ["hi"]).success, "should FAIL to call wrong function with correct argument")
        XCTAssertFalse(testClass.didCall(.doWeirdStuffWith, withArguments: ["nope"]).success, "should FAIL to call wrong function")
    }

    func testDidCallFunctionWithOptionalArguments() {
        // given
        let testClass = TestClass()

        // when
        testClass.doWeirdStuffWith(string: "hello", int: nil)

        // then
        XCTAssertTrue(testClass.didCall(.doWeirdStuffWith, withArguments: ["hello" as String?, nil as Int?]).success, "should SUCCEED to call correct function with correct Optional values")
        XCTAssertTrue(testClass.didCall(.doWeirdStuffWith, withArguments: ["hello", Optional<Int>.none]).success, "should SUCCEED to call correct function with correct but Non-Optional values")
        XCTAssertTrue(testClass.didCall(.doWeirdStuffWith, withArguments: ["hello" as String?, nil as Any?]).success, "should SUCCEED to call correct function with incorrect Optional value type but correct 'nil'ness")
    }

    func testDidCallFunctionWithArgumentsANumberOfTimes() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")

        // then
        XCTAssertTrue(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .exactly(2)).success, "should SUCCEED to call function with arguments 2 times")
        XCTAssertFalse(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .exactly(1)).success, "should FAIL to call function with arguments 1 time")
        XCTAssertFalse(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .exactly(3)).success, "should FAIL to call function with arguments 3 times")
    }

    func testDidCallFunctionWithArgumentsAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")

        // then
        XCTAssertTrue(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .atLeast(2)).success, "should SUCCEED to call function with arguments at least 2 times")
        XCTAssertTrue(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .atLeast(1)).success, "should SUCCEED to call function with arguments at least 1 time")
        XCTAssertFalse(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .atLeast(3)).success, "should FAIL to call function with arguments 3 times")
    }

    func testDidCallFunctionWithArgumentsAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()

        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")

        // then
        XCTAssertTrue(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .atMost(2)).success, "should SUCCEED to call function with arguments at most 2 times")
        XCTAssertTrue(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .atMost(3)).success, "should SUCCEED to call function with arguments at most 3 times")
        XCTAssertFalse(testClass.didCall(.doStuffWith, withArguments: ["hello"], countSpecifier: .atMost(1)).success, "should FAIL to call function with arguments at most 1 time")
    }

    // MARK: - Argument Enum Tests

    func testAnythingArgument() {
        // given
        let testClass = TestClass()

        // when
        testClass.doMoreStuffWith(int1: 1, int2: 5)
        testClass.doWeirdStuffWith(string: "hi", int: nil)

        // then
        XCTAssertTrue(testClass.didCall(.doMoreStuffWith, withArguments: [Argument.anything, Argument.anything]).success, "should SUCCEED to call function with 'anything' and 'anything' arguments")
        XCTAssertTrue(testClass.didCall(.doWeirdStuffWith, withArguments: [Argument.anything, Argument.anything]).success, "should SUCCEED to call function with 'anything' and 'anything' arguments")
    }

    func testNonNilArgument() {
        // given
        let testClass = TestClass()

        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)

        // then
        XCTAssertTrue(testClass.didCall(.doWeirdStuffWith, withArguments: [Argument.nonNil, Argument.anything]).success, "should SUCCEED to call function with 'non-nil' and 'anything' arguments")
        XCTAssertFalse(testClass.didCall(.doWeirdStuffWith, withArguments: [Argument.anything, Argument.nonNil]).success, "should FAIL to call function with 'anything' and 'non-nil' arguments")
    }

    func testNilArgument() {
        // given
        let testClass = TestClass()

        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)

        // then
        XCTAssertTrue(testClass.didCall(.doWeirdStuffWith, withArguments: [Argument.anything, Argument.nil]).success, "should SUCCEED to call function with 'anything' and 'nil' arguments")
        XCTAssertFalse(testClass.didCall(.doWeirdStuffWith, withArguments: [Argument.nil, Argument.anything]).success, "should FAIL to call function with 'nil' and 'anything' arguments")
    }

    // MARK: - Did Call - Recorded Calls Description Tests

    func testRecordedCallsDescriptionNoCalls() {
        // given
        let testClass = TestClass()

        // when
        let result = testClass.didCall(.doStuff)

        // then
        XCTAssertEqual(result.recordedCallsDescription, "<>")
    }

    func testRecordedCallsDescriptionSingleCallWithNoArguments() {
        // given
        let testClass = TestClass()
        testClass.doStuff()

        // when
        let result = testClass.didCall(.doStuff)

        // then
        XCTAssertEqual(result.recordedCallsDescription, "<doStuff()>")
    }

    func testRecordedCallsDescriptionSingleCallWithArguments() {
        // given
        let testClass = TestClass()
        testClass.doMoreStuffWith(int1: 5, int2: 10)

        // when
        let result = testClass.didCall(.doStuff)

        // then
        XCTAssertEqual(result.recordedCallsDescription, "<doMoreStuffWith(int1:int2:) with 5, 10>")
    }

    func testRecordedCallsDescriptionMultipleCalls() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doMoreStuffWith(int1: 5, int2: 10)

        // when
        let result = testClass.didCall(.doWeirdStuffWith)

        // then
        XCTAssertEqual(result.recordedCallsDescription, "<doStuff()>, <doMoreStuffWith(int1:int2:) with 5, 10>")
    }
}
