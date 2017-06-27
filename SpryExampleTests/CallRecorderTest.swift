import XCTest
import SpryExample

extension String: GloballyEquatable {}
extension Int: GloballyEquatable {}
extension NSObject: GloballyEquatable {}
extension Optional: GloballyEquatable {}

private class TestClass: CallRecorder {
    var _calls = (functionList: [String](), argumentsList: [[GloballyEquatable]]())

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

class CallRecorderTest: XCTestCase {

    // MARK: - Recording Tests

    func testRecordingFunctions() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuffWith(string: "asd")
        
        // then
        let expectedRecordedFunctions = ["doStuff()", "doStuff()", "doStuffWith(string:)"]
        XCTAssertEqual(testClass._calls.functionList, expectedRecordedFunctions, "should record function names in order")
    }
    
    func testRecordingArguments() { // most of these 'asserts' are here because Swift's 'Any' Protocol is not Equatable
        // given
        let testClass = TestClass()
        let expectedSet1Arg1 = "foo"
        let expectedSet2Arg1 = 1
        let expectedSet2Arg2 = 2
        let expectedSet3Arg1 = "bar"
        
        // when
        testClass.doStuffWith(string: expectedSet1Arg1)
        testClass.doMoreStuffWith(int1: expectedSet2Arg1, int2: expectedSet2Arg2)
        testClass.doStuffWith(string: expectedSet3Arg1)
        
        // then
        let countFailureMessage = { (input: (count: Int, set: Int)) -> String in
            return "should have \(input.count) argument(s) in set \(input.set)"
        }

        let typeFailureMessage = { (input: (set: Int, arg: Int)) -> String in
            return "should match type for set \(input.set), argument \(input.arg)"
        }

        let descFailureMessage = { (input: (set: Int, arg: Int)) -> String in
            return "should match string interpolation for set \(input.set), argument \(input.arg)"
        }

        let actualset1Arg1 = testClass._calls.argumentsList[0][0]
        let actualset2Arg1 = testClass._calls.argumentsList[1][0]
        let actualset2Arg2 = testClass._calls.argumentsList[1][1]
        let actualset3Arg1 = testClass._calls.argumentsList[2][0]

        XCTAssertEqual(testClass._calls.argumentsList.count, 3, "should have 3 sets of arguments")

        XCTAssertEqual(testClass._calls.argumentsList[0].count, 1, countFailureMessage((count: 1, set: 1)))
        XCTAssertEqual("\(type(of: actualset1Arg1))", "\(type(of: expectedSet1Arg1))", typeFailureMessage((set: 1, arg: 1)))
        XCTAssertEqual("\(actualset1Arg1)", "\(expectedSet1Arg1)", descFailureMessage((set: 1, arg: 1)))
        
        XCTAssertEqual(testClass._calls.argumentsList[1].count, 2, countFailureMessage((count: 2, set: 2)))
        XCTAssertEqual("\(type(of: actualset2Arg1))", "\(type(of: expectedSet2Arg1))", typeFailureMessage((set: 2, arg: 1)))
        XCTAssertEqual("\(actualset2Arg1)", "\(expectedSet2Arg1)", descFailureMessage((set: 2, arg: 1)))
        XCTAssertEqual("\(type(of: actualset2Arg2))", "\(type(of: expectedSet2Arg2))", typeFailureMessage((set: 2, arg: 2)))
        XCTAssertEqual("\(actualset2Arg2)", "\(expectedSet2Arg2)", descFailureMessage((set: 2, arg: 2)))

        XCTAssertEqual(testClass._calls.argumentsList[2].count, 1, countFailureMessage((count: 1, set: 3)))
        XCTAssertEqual("\(type(of: actualset3Arg1))", "\(type(of: expectedSet3Arg1))", typeFailureMessage((set: 3, arg: 1)))
        XCTAssertEqual("\(actualset3Arg1)", "\(expectedSet3Arg1)", descFailureMessage((set: 3, arg: 1)))
    }
    
    func testResettingTheRecordedLists() {
        // given
        let testClass = TestClass()
        testClass.doStuffWith(string: "foo")
        testClass.doMoreStuffWith(int1: 1, int2: 2)
        
        // when
        testClass.clearRecordedLists()
        testClass.doStuffWith(string: "bar")
        
        // then
        XCTAssertEqual(testClass._calls.functionList.count, 1, "should have 1 function recorded")
        let recordedFunction = testClass._calls.functionList[0] // <- swift doesn't like accessing an array directly in the expect function
        XCTAssertEqual(recordedFunction, "doStuffWith(string:)", "should have correct function recorded")
        
        XCTAssertEqual(testClass._calls.argumentsList.count, 1, "should have 1 set of arguments recorded")
        XCTAssertEqual(testClass._calls.argumentsList[0].count, 1, "should have 1 argument in first argument set")
        XCTAssertEqual("\(testClass._calls.argumentsList[0][0])", "bar", "should have correct argument in first argument set recorded")
    }
    
    // MARK: - Did Call Tests
    
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
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .Exactly(2)).success, "should SUCCEED to call function 2 times")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .Exactly(1)).success, "should FAIL to call the function 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .Exactly(3)).success, "should FAIL to call the function 3 times")
    }
    
    func testDidCallFunctionAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .AtLeast(2)).success, "should SUCCEED to call function at least 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .AtLeast(1)).success, "should SUCCEED to call function at least 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .AtLeast(3)).success, "should FAIL to call function at least 3 times")
    }
    
    func testDidCallFunctionAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .AtMost(2)).success, "should SUCCEED to call function at most 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuff()", countSpecifier: .AtMost(3)).success, "should SUCCEED to call function at most 3 times")
        XCTAssertFalse(testClass.didCall(function: "doStuff()", countSpecifier: .AtMost(1)).success, "should FAIL to call function at most 1 time")
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
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .Exactly(2)).success, "should SUCCEED to call function with arguments 2 times")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .Exactly(1)).success, "should FAIL to call function with arguments 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .Exactly(3)).success, "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtLeast(2)).success, "should SUCCEED to call function with arguments at least 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtLeast(1)).success, "should SUCCEED to call function with arguments at least 1 time")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtLeast(3)).success, "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtMost(2)).success, "should SUCCEED to call function with arguments at most 2 times")
        XCTAssertTrue(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtMost(3)).success, "should SUCCEED to call function with arguments at most 3 times")
        XCTAssertFalse(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtMost(1)).success, "should FAIL to call function with arguments at most 1 time")
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
        
        let expectedArgs1: Array<GloballyEquatable> = [Argument.instanceOf(type: Optional<String>.self), Argument.instanceOf(type: Optional<Int>.self)]
        XCTAssertTrue(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs1).success, "should SUCCEED to call function with 'instance of String?' and ' instance of Int?' arguments")
        let expectedArgs2: Array<GloballyEquatable> = [Argument.instanceOf(type: String.self), Argument.instanceOf(type: Int.self)]
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
