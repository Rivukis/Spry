import XCTest
import Nimble

extension String : GloballyEquatable {}
extension Int : GloballyEquatable {}
extension NSObject : GloballyEquatable {}
extension Optional : GloballyEquatable, Equatable {}

/*
Would like to use Mirror here but there is currently a bug in Swift (I have filed an issue on the Swift project Jira board: SR-1132)
When that one gets fixed this won't have to be done on the client's side and instead handled automatically also without making Optional
conform to Equatable
*/
public func ==<T>(lhs: Optional<T>, rhs: Optional<T>) -> Bool {
    if let lhs = lhs, rhs = rhs {
        guard let lhsGE = lhs as? GloballyEquatable else {
            assertionFailure("type '\(lhs.self)' does not conform to 'GloballyEquatable'")
            return false
        }
        
        guard let rhsGE = rhs as? GloballyEquatable else {
            assertionFailure("type '\(rhs.self)' does not conform to 'GloballyEquatable'")
            return false
        }
        
        return lhsGE.isEqualTo(rhsGE)
    }
    
    let leftIsReal : Bool
    if let _ = lhs {
        leftIsReal = true
    } else {
        leftIsReal = false
    }
    
    let rightIsReal : Bool
    if let _ = lhs {
        rightIsReal = true
    } else {
        rightIsReal = false
    }
    
    return !leftIsReal && !rightIsReal // allows two Optional<T>.None to equate to true
}

class CallRecorderTest: XCTestCase {
    
    class TestClass : CallRecorder {
        var called = (functionList: [String](), argumentsList: [[GloballyEquatable]]())
        
        func doStuff() {
            self.recordCall()
        }
        
        func doStuffWith(string string: String) {
            self.recordCall(arguments: string)
        }
        
        func doMoreStuffWith(int1 int1: Int, int2: Int) {
            self.recordCall(arguments: int1, int2)
        }
        
        func doWeirdStuffWith(string string: String?, int: Int?) {
            self.recordCall(arguments: string, int)
        }
        
        func doCrazyStuffWith(object object: NSObject) {
            self.recordCall(arguments: object)
        }
    }
    
    // Recording Tests
    
    func testRecordingFunctions() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        testClass.doStuffWith(string: "asd")
        
        // then
        let expectedRecordedFunctions = ["doStuff()", "doStuff()", "doStuffWith(string:)"]
        expect(testClass.called.functionList).to(equal(expectedRecordedFunctions), description: "should record function names in order")
    }
    
    func testRecordingArguments() { // most of these 'expects' are here because Swift's 'Any' Protocol is not Equatable
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
        func countFailureMessage(count count: Int, set: Int) -> String {return "should have \(count) argument(s) in set \(set)" }
        func typeFailureMessage(set set: Int, arg: Int) -> String { return "should match type for set \(set), argument \(arg)" }
        func descFailureMessage(set set: Int, arg: Int) -> String { return "should match string interpolation for set \(set), argument \(arg)" }
        
        let actualset1Arg1 = testClass.called.argumentsList[0][0]
        let actualset2Arg1 = testClass.called.argumentsList[1][0]
        let actualset2Arg2 = testClass.called.argumentsList[1][1]
        let actualset3Arg1 = testClass.called.argumentsList[2][0]
        
        expect(testClass.called.argumentsList.count).to(equal(3), description: "should have 3 sets of arguments")
        
        expect(testClass.called.argumentsList[0].count).to(equal(1), description: countFailureMessage(count: 1, set: 1))
        expect("\(actualset1Arg1.dynamicType)").to(equal("\(expectedSet1Arg1.dynamicType)"), description: typeFailureMessage(set: 1, arg: 1))
        expect("\(actualset1Arg1)").to(equal("\(expectedSet1Arg1)"), description: descFailureMessage(set: 1, arg: 1))
        
        expect(testClass.called.argumentsList[1].count).to(equal(2), description: countFailureMessage(count: 2, set: 2))
        expect("\(actualset2Arg1.dynamicType)").to(equal("\(expectedSet2Arg1.dynamicType)"), description: typeFailureMessage(set: 2, arg: 1))
        expect("\(actualset2Arg1)").to(equal("\(expectedSet2Arg1)"), description: descFailureMessage(set: 2, arg: 1))
        expect("\(actualset2Arg2.dynamicType)").to(equal("\(expectedSet2Arg2.dynamicType)"), description: typeFailureMessage(set: 2, arg: 2))
        expect("\(actualset2Arg2)").to(equal("\(expectedSet2Arg2)"), description: descFailureMessage(set: 2, arg: 2))

        expect(testClass.called.argumentsList[2].count).to(equal(1), description: countFailureMessage(count: 1, set: 3))
        expect("\(actualset3Arg1.dynamicType)").to(equal("\(expectedSet3Arg1.dynamicType)"), description: typeFailureMessage(set: 3, arg: 1))
        expect("\(actualset3Arg1)").to(equal("\(expectedSet3Arg1)"), description: descFailureMessage(set: 3, arg: 1))
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
        expect(testClass.called.functionList.count).to(equal(1), description: "should have 1 function recorded")
        let recordedFunction = testClass.called.functionList[0] // <- swift doesn't like accessing an array directly in the expect function
        expect(recordedFunction).to(equal("doStuffWith(string:)"), description: "should have correct function recorded")
        
        expect(testClass.called.argumentsList.count).to(equal(1), description: "should have 1 set of arguments recorded")
        expect(testClass.called.argumentsList[0].count).to(equal(1), description: "should have 1 argument in first argument set")
        expect("\(testClass.called.argumentsList[0][0])").to(equal("bar"), description: "should have correct argument in first argument set recorded")
    }
    
    // MARK: Did Call Tests
    
    func testDidCallFunction() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function")
        expect(testClass.didCall(function: "neverGonnaCall()", recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function")
    }
    
    func testDidCallFunctionANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .Exactly(2), recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function 2 times")
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .Exactly(1), recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call the function 1 time")
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .Exactly(3), recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call the function 3 times")
    }
    
    func testDidCallFunctionAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .AtLeast(2), recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at least 2 times")
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .AtLeast(1), recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at least 1 time")
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .AtLeast(3), recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function at least 3 times")
    }
    
    func testDidCallFunctionAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuff()
        testClass.doStuff()
        
        // then
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .AtMost(2), recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at most 2 times")
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .AtMost(3), recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function at most 3 times")
        expect(testClass.didCall(function: "doStuff()", countSpecifier: .AtMost(1), recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function at most 1 time")
    }
    
    func testDidCallFunctionWithArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hi"], recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call correct function with correct arguments")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call correct function with wrong arguments")
        expect(testClass.didCall(function: "neverGonnaCallWith(string:)", withArguments: ["hi"], recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call wrong function with correct argument")
        expect(testClass.didCall(function: "neverGonnaCallWith(string:)", withArguments: ["nope"], recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call wrong function")
    }
    
    func testDidCallFunctionWithOptionalArguments() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hello", int: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: ["hello" as String?, nil as Int?], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call correct funtion with correct Optional values")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: ["hello", Optional<Int>.None], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call correct funtion with correct but Non-Optional values")
    }
    
    func testDidCallFunctionWithArgumentsANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .Exactly(2), recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with arguments 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .Exactly(1), recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with arguments 1 time")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .Exactly(3), recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtLeastANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtLeast(2), recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at least 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtLeast(1), recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at least 1 time")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtLeast(3), recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call function with arguments 3 times")
    }
    
    func testDidCallFunctionWithArgumentsAtMostANumberOfTimes() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hello")
        testClass.doStuffWith(string: "hi")
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtMost(2), recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at most 2 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtMost(3), recordedCallsDescOption: .No).success).to(beTrue(),
            description: "should SUCCEED to call function with arguments at most 3 times")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: ["hello"], countSpecifier: .AtMost(1), recordedCallsDescOption: .No).success).to(beFalse(),
            description: "should FAIL to call function with arguments at most 1 time")
    }
    
    // MARK: Argument Enum Tests
    
    func testArgumentEnumDiscription() {
        // given
        let anything = Argument.Anything
        let nonNil = Argument.NonNil
        let nilly = Argument.Nil
        let instanceOf = Argument.InstanceOf(type: String.self)
        let instanceOfWith = Argument.InstanceOfWith(type: String.self, option: .Anything)
        let kindOf = Argument.KindOf(type: NSObject.self)
        
        // then
        expect("\(anything)").to(equal("Argument.Anything"))
        expect("\(nonNil)").to(equal("Argument.NonNil"))
        expect("\(nilly)").to(equal("Argument.Nil"))
        expect("\(instanceOf)").to(equal("Argument.InstanceOf(String)"))
        expect("\(instanceOfWith)").to(equal("Argument.InstanceOfWith(String, ArgumentOption.Anything)"))
        expect("\(kindOf)").to(equal("Argument.KindOf(NSObject)"))
    }
    
    func testArgumentOptionEnumDescription() {
        let anything = ArgumentOption.Anything
        let nonOptional = ArgumentOption.NonOptional
        let optional = ArgumentOption.Optional
        
        // then
        expect("\(anything)").to(equal("ArgumentOption.Anything"))
        expect("\(nonOptional)").to(equal("ArgumentOption.NonOptional"))
        expect("\(optional)").to(equal("ArgumentOption.Optional"))
    }
    
    func testAnythingArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doMoreStuffWith(int1: 1, int2: 5)
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doMoreStuffWith(int1:int2:)", withArguments: [Argument.Anything, Argument.Anything], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with 1 and dont care")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.Anything, Argument.Anything], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with non-nil and dont care arguments")
    }
    
    func testNonNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.NonNil, Argument.Anything], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with non-nil and dont care arguments")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.Anything, Argument.NonNil], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with non-nil and non-nil arguments")
    }
    
    func testNilArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.Anything, Argument.Nil], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with dont care and nil arguments")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.Nil, Argument.Anything], recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with nil and dont care arguments")
    }
    
    func testInstanceOfArgument() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: nil)
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOf(type: String.self)], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with instance of String argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOf(type: Int.self)], recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with instance of Int argument")
        
        let expectedArgs1: Array<GloballyEquatable> = [Argument.InstanceOf(type: Optional<String>.self), Argument.InstanceOf(type: Optional<Int>.self)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs1, recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with instance of String? and Int? arguments")
        let expectedArgs2: Array<GloballyEquatable> = [Argument.InstanceOf(type: String.self), Argument.InstanceOf(type: Int.self)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs2, recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with String and Int arguments")
    }
    
    func testInstanceOfWithArgumentAnythingArgumentOption() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: 5)
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOfWith(type: String.self, option: .Anything)], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with instance of String with optional requirement 'dont care' argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOfWith(type: Int.self, option: .Anything)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with instance of Int with optional requirement 'dont care' argument")
    }
    
    func testInstanceOfWithArgumentNonOptionalArgumentOption() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: 5)
        
        // then
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOfWith(type: String.self, option: .NonOptional)], recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with instance of String with optional requirement 'non-optional' argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOfWith(type: Int.self, option: .NonOptional)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with instance of Int with optional requirement 'non-optional' argument")
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: [Argument.Anything, Argument.InstanceOfWith(type: Int.self, option: .NonOptional)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with 'dont care' and instance of Int with optional requirement 'non-optional' arguments")
    }
    
    func testInstanceOfWithArgumentOptionalArgumentOption() {
        // given
        let testClass = TestClass()
        
        // when
        testClass.doStuffWith(string: "hello")
        testClass.doWeirdStuffWith(string: "hi", int: 5)
        
        // then
        let expectedArgs1: Array<GloballyEquatable> = [Argument.Anything, Argument.InstanceOfWith(type: Int.self, option: .Optional)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs1, recordedCallsDescOption: .No).success).to(beTrue(), description: "should SUCCEED to call function with 'dont care' and instance of Int with optional requirement 'optional' argument")
        let expectedArgs2: Array<GloballyEquatable> = [Argument.Anything, Argument.InstanceOfWith(type: String.self, option: .Optional)]
        expect(testClass.didCall(function: "doWeirdStuffWith(string:int:)", withArguments: expectedArgs2, recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with 'dont care' and instance of String with optional requirement 'optional' argument")
        expect(testClass.didCall(function: "doStuffWith(string:)", withArguments: [Argument.InstanceOfWith(type: String.self, option: .Optional)], recordedCallsDescOption: .No).success).to(beFalse(), description: "should FAIL to call function with instance of String with optional requirement 'optional' arguments")
    }
    
    func testKindOfClassArgument() {
        // given
        class SubClass : NSObject {}
        class SubSubClass : SubClass {}
        let testClass = TestClass()
        
        // when
        testClass.doCrazyStuffWith(object: SubClass())
        
        // then
        expect(testClass.didCall(function: "doCrazyStuffWith(object:)", withArguments: [Argument.KindOf(type: NSObject.self)], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with kind of NSObject argument")
        expect(testClass.didCall(function: "doCrazyStuffWith(object:)", withArguments: [Argument.KindOf(type: SubClass.self)], recordedCallsDescOption: .No).success)
            .to(beTrue(), description: "should SUCCEED to call function with kind of SubClass argument")
        expect(testClass.didCall(function: "doCrazyStuffWith(object:)", withArguments: [Argument.KindOf(type: SubSubClass.self)], recordedCallsDescOption: .No).success)
            .to(beFalse(), description: "should FAIL to call function with kind of SubSubClass argument")
    }
    
    // MARK: Did Call - Recorded Calls Description Option Tests
    
    func testDidCallResultShouldIncludeOptionEnumDiscription() {
        // given
        let yes = DidCallResultIncludeOption.Yes
        let no = DidCallResultIncludeOption.No
        let onlyOnSuccess = DidCallResultIncludeOption.OnlyOnSuccess
        let onlyOnUnsuccess = DidCallResultIncludeOption.OnlyOnUnsuccess
        
        // then
        expect("\(yes)").to(equal("DidCallResultIncludeOption.Yes"))
        expect("\(no)").to(equal("DidCallResultIncludeOption.No"))
        expect("\(onlyOnSuccess)").to(equal("DidCallResultIncludeOption.OnlyOnSuccess"))
        expect("\(onlyOnUnsuccess)").to(equal("DidCallResultIncludeOption.OnlyOnUnsuccess"))
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionYes() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let passingResult = testClass.didCall(function: "doStuff()", recordedCallsDescOption: .Yes)
        let failingResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        
        // then
        let recordedCallsDescriptions = [
            passingResult.recordedCallsDescription,
            failingResult.recordedCallsDescription
        ]
        
        expect(recordedCallsDescriptions).to(allPass(equal("<doStuff()>")))
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionNo() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let passingResult = testClass.didCall(function: "doStuff()", recordedCallsDescOption: .No)
        let failingResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .No)
        
        // then
        let recordedCallsDescriptions = [
            passingResult.recordedCallsDescription,
            failingResult.recordedCallsDescription
        ]
        
        expect(recordedCallsDescriptions).to(allPass(beEmpty()))
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionOnlyOnSuccess() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let passingResult = testClass.didCall(function: "doStuff()", recordedCallsDescOption: .OnlyOnSuccess)
        let failingResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .OnlyOnSuccess)
        
        // then
        expect(passingResult.recordedCallsDescription).to(equal("<doStuff()>"))
        expect(failingResult.recordedCallsDescription).to(beEmpty())
    }
    
    func testDidCallResultShouldIncludeDescriptionOptionOnlyOnUnsuccess() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let passingResult = testClass.didCall(function: "doStuff()", recordedCallsDescOption: .OnlyOnUnsuccess)
        let failingResult = testClass.didCall(function: "not a function", recordedCallsDescOption: .OnlyOnUnsuccess)
        
        // then
        expect(passingResult.recordedCallsDescription).to(beEmpty())
        expect(failingResult.recordedCallsDescription).to(equal("<doStuff()>"))
    }
    
    // MARK: Did Call - Recorded Calls Description Tests
    
    func testRecordedCallsDescriptionNoCalls() {
        // given
        let testClass = TestClass()
        
        // when
        let result = testClass.didCall(function: "", recordedCallsDescOption: .Yes)
        
        // then
        expect(result.recordedCallsDescription).to(equal("<>"))
    }
    
    func testRecordedCallsDescriptionSingleCallWithNoArguments() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        
        // when
        let result = testClass.didCall(function: "", recordedCallsDescOption: .Yes)
        
        // then
        expect(result.recordedCallsDescription).to(equal("<doStuff()>"))
    }
    
    func testRecordedCallsDescriptionSingleCallWithArguments() {
        // given
        let testClass = TestClass()
        testClass.doMoreStuffWith(int1: 5, int2: 10)
        
        // when
        let result = testClass.didCall(function: "", recordedCallsDescOption: .Yes)
        
        // then
        expect(result.recordedCallsDescription).to(equal("<doMoreStuffWith(int1:int2:) with 5, 10>"))
    }
    
    func testRecordedCallsDescriptionMultipleCalls() {
        // given
        let testClass = TestClass()
        testClass.doStuff()
        testClass.doMoreStuffWith(int1: 5, int2: 10)
        
        // when
        let result = testClass.didCall(function: "not a function", recordedCallsDescOption: .Yes)
        
        // then
        expect(result.recordedCallsDescription).to(equal("<doStuff()>, <doMoreStuffWith(int1:int2:) with 5, 10>"))
    }
}