import XCTest
import SpryExample

class ArgumentTest: XCTestCase {
    func testArgumentEnumDiscription() {
        // given
        let anything = Argument.Anything
        let nonNil = Argument.NonNil
        let nilly = Argument.Nil
        let instanceOf = Argument.InstanceOf(type: String.self)

        // then
        XCTAssertEqual("\(anything)", "Argument.Anything")
        XCTAssertEqual("\(nonNil)", "Argument.NonNil")
        XCTAssertEqual("\(nilly)", "Argument.Nil")
        XCTAssertEqual("\(instanceOf)", "Argument.InstanceOf(String)")
    }
}
