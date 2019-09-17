//
//  Spryable+TestHelper.swift
//  SpryExampleTests
//
//  Created by Brian Radebaugh on 11/5/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

import Foundation

class SpryableTestClass: Spryable {
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
