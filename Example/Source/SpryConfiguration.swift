//
//  SpryConfiguration.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 3/25/18.
//  Copyright © 2018 Brian Radebaugh. All rights reserved.
//

import Foundation

/**
 This is used to house all of Spry's configuration settings.
 */
class SpryConfiguration {
    /**
     This closure is ran everytime Spry calls fatal error.

     This is a convenience against Xcode not printing out fatal error messages when `fatalError()` is called.

     - Note: Xcode sometimes crashes when `fatalError()` is called. I recommend putting a break point on `fatalError()` in file FatalError.swift (near the top of the file). Then, let the default printing of the error message in `fatalErrorClosure` print the message instead of `fatalError()`. This will prevent Xcode from running the `fatalError()` line of code, thus preventing it from ever crashing.
     */
    public static var fatalErrorClosure: (String) -> Void = { errorString in
        print(errorString)
    }
}
