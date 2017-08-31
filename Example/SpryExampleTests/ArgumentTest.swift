//
//  ArgumentTest.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 11/3/15.
//  Copyright © 2015 Brian Radebaugh. All rights reserved.
//

import XCTest
import SpryExample

class ArgumentTest: XCTestCase {
    func testArgumentEnumDiscription() {
        // given
        let anything = Argument.anything
        let nonNil = Argument.nonNil
        let nilly = Argument.nil
        let pass = Argument.pass({ _ in return true })

        // then
        XCTAssertEqual("\(anything)", "Argument.anything")
        XCTAssertEqual("\(nonNil)", "Argument.nonNil")
        XCTAssertEqual("\(nilly)", "Argument.nil")
        XCTAssertEqual("\(pass)", "Argument.pass")
    }
}
