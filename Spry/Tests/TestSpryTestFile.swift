//
//  TestSpryTestFile.swift
//  Spry
//
//  Created by Brian Radebaugh on 8/3/16.
//
//

import XCTest
import Spry

class TestSpryTestFile: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        print("----->", NSProcessInfo.processInfo().operatingSystemVersionString)
        
        XCTAssertEqual(otherTestString(), "bar")
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
