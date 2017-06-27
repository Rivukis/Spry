import XCTest
import SpryExample

class ArgumentTest: XCTestCase {
    func testArgumentEnumDiscription() {
        // given
        let anything = Argument.anything
        let nonNil = Argument.nonNil
        let nilly = Argument.nil
        let instanceOf = Argument.instanceOf(type: String.self)

        // then
        XCTAssertEqual("\(anything)", "Argument.Anything")
        XCTAssertEqual("\(nonNil)", "Argument.NonNil")
        XCTAssertEqual("\(nilly)", "Argument.Nil")
        XCTAssertEqual("\(instanceOf)", "Argument.InstanceOf(String)")
    }
}
