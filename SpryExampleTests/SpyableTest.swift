//
//  SpyableTest.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/1/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import XCTest
import SpryExample

extension String: AnyEquatable {}
extension Int: AnyEquatable {}
extension NSObject: AnyEquatable {}
extension Optional: AnyEquatable {}

private class TestClass: Spyable {
    var _calls: [RecordedCall] = []

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

    // MARK: - Resetting

    func testResettingTheRecordedLists() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "foo")
        testClass.doMoreStuffWith(int1: 1, int2: 2)
        
        // when
        testClass.clearRecordedLists()
        testClass.doStuffWith(string: "bar")
        
        // then
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["foo"]).success, "should SUCCEED to call function")
        XCTAssertFalse(testClass.didCall(function: "doMoreStuffWith(int1:int2:)", withArguments: [1, 2]).success, "should SUCCEED to call function")
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["bar"]).success, "should SUCCEED to call function")
    }

    // MARK: - Did Call Tests

    func testDidCallIvarProperty() {
        // given
        let testClass = TestClass()

        // when
        testClass.ivarProperty = "new value"

        // then
        XCTAssertTrue(testClass.didCall(function: "ivarProperty").success, "should SUCCEED to set property")
        XCTAssertTrue(testClass.didCall(function: "ivarProperty", withArguments: ["new value"]).success, "should SUCCEED to set property with new value")
    }

    func testDidCallReadOnlyProperty() {
        // given
        let testClass = TestClass()

        // when
        testClass.readOnlyProperty = "new value"

        // then
        XCTAssertTrue(testClass.didCall(function: "readOnlyProperty").success, "should SUCCEED to set property")
        XCTAssertTrue(testClass.didCall(function: "readOnlyProperty", withArguments: ["new value"]).success, "should SUCCEED to set property with new value")
    }
    
    func testDidCallFunction() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuff()").success, "should SUCCEED to call function")
        XCTAssertFalse(testClass.didCall(function: "neverGonnaCall()").success, "should FAIL to call function")
    }
    
    func testDidCallFunctionANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .exactly(2)).success, "should SUCCEED to call function 2 times")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .exactly(1)).success, "should FAIL to call the function 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .exactly(3)).success, "should FAIL to call the function 3 times")
    }
    
    func testDidCallFunctionAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .atLeast(2)).success, "should SUCCEED to call function at least 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .atLeast(1)).success, "should SUCCEED to call function at least 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .atLeast(3)).success, "should FAIL to call function at least 3 times")
    }
    
    func testDidCallFunctionAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .atMost(2)).success, "should SUCCEED to call function at most 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .atMost(3)).success, "should SUCCEED to call function at most 3 times")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .atMost(1)).success, "should FAIL to call function at most 1 time")
    }
    
    func testDidCallFunctionWithArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hi")
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hi"]).success, "should SUCCEED to call correct function with correct arguments")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"]).success, "should FAIL to call correct function with wrong arguments")
        XCTAssertFalse(testClass.didCall(function: "neverGonnaCallWith(string:)", withArguments: ["hi"]).success, "should FAIL to call wrong function with correct argument")
        XCTAssertFalse(testClass.didCall(function: "neverGonnaCallWith(string:)", withArguments: ["nope"]).success, "should FAIL to call wrong function")
    }
    
    func testDidCallFunctionWithOptionalArguments() {
        // given
        let testClass = TestClass()
                
        // when
        testClass.doWeirdStuffWith(string: "hello", int: nil)
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: ["hello" as String?, nil as Int?]).success, "should SUCCEED to call correct function with correct Optional values")
        XCTAssertFalse(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: ["hello", Optional<Int>.none]).success, "should FAIL to call correct function with correct but Non-Optional values")
    }
    
    func testDidCallFunctionWithArgumentsANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .exactly(2)).success, "should SUCCEED to call function with arguments 2 times")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .exactly(1)).success, "should FAIL to call function with arguments 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .exactly(3)).success, "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .atLeast(2)).success, "should SUCCEED to call function with arguments at least 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .atLeast(1)).success, "should SUCCEED to call function with arguments at least 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .atLeast(3)).success, "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .atMost(2)).success, "should SUCCEED to call function with arguments at most 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .atMost(3)).success, "should SUCCEED to call function with arguments at most 3 times")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .atMost(1)).success, "should FAIL to call function with arguments at most 1 time")
    }
    
    // MARK: - Argument Enum Tests

    func testAnythingArgument() {
        // given
        let testClass = TestClass()

        // when
        testClass.doMoreStuffWith(int1: 1, int2: 5)
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doMoreStuffWith(int1:int2:)", withArguments: [Argument.anything, Argument.anything]).success, "should SUCCEED to call function with 'anything' and 'anything' arguments")
        XCTAssertTrue(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.anything, Argument.anything]).success, "should SUCCEED to call function with 'anything' and 'anything' arguments")
    }
    
    func testNonNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.nonNil, Argument.anything]).success, "should SUCCEED to call function with 'non-nil' and 'anything' arguments")
        XCTAssertFalse(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.anything, Argument.nonNil]).success, "should FAIL to call function with 'anything' and 'non-nil' arguments")
    }
    
    func testNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.anything, Argument.nil]).success, "should SUCCEED to call function with 'anything' and 'nil' arguments")
        XCTAssertFalse(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.nil, Argument.anything]).success, "should FAIL to call function with 'nil' and 'anything' arguments")
    }
    
    func testInstanceOfArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.instanceOf(type: String.self)]).success, "should SUCCEED to call function with 'instance of String' argument")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.instanceOf(type: Int.self)]).success, "should FAIL to call function with 'instance of Int' argument")
        
        let expectedArgs1: [AnyEquatable] = [Argument.instanceOf(type: Optional<String>.self), Argument.instanceOf(type: Optional<Int>.self)]
        XCTAssertTrue(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs1).success, "should SUCCEED to call function with 'instance of String?' and ' instance of Int?' arguments")
        let expectedArgs2: [AnyEquatable] = [Argument.instanceOf(type: String.self), Argument.instanceOf(type: Int.self)]
        XCTAssertFalse(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs2).success, "should FAIL to call function with 'instance of String' and 'instance of Int' arguments")
    }

    // MARK: - Did Call - Recorded Calls Description Tests

    func testRecordedCallsDescriptionNoCalls() {
        // given
        let testClass = TestClass()
        
        // when
        let result = testClass.didCall(function: "")
        
        // then
        XCTAssertEqual(result.recordedCallsDescription, "<>")
    }
    
    func testRecordedCallsDescriptionSingleCallWithNoArguments() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let result = testClass.didCall(function: "")
        
        // then
        XCTAssertEqual(result.recordedCallsDescription, "<doStuff()>")
    }
    
    func testRecordedCallsDescriptionSingleCallWithArguments() {
        // given
        let testClass = TestClass()
        testClass.doMoreStuffWith(int1: 5, int2: 10)
        
        // when
        let result = testClass.didCall(function: "")
        
        // then
        XCTAssertEqual(result.recordedCallsDescription, "<doMoreStuffWith(int1:int2:) with 5, 10>")
    }
    
    func testRecordedCallsDescriptionMultipleCalls() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doMoreStuffWith(int1: 5, int2: 10)
        
        // when
        let result = testClass.didCall(function: "not a function")
        
        // then
        XCTAssertEqual(result.recordedCallsDescription, "<doStuff()>, <doMoreStuffWith(int1:int2:) with 5, 10>")
    }
}
