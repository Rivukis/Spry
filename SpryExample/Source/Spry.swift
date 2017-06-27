//
//  Spry.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

/**
 Convenience protocol to conform to both Mocker and Stubber at the same time.
 
 ## Example Conformance ##
 ```swift
 var _spryVariable: (_calls: [RecordedCall], _stubs: [Stub]) = ([], [])
 ```
 */
protocol Spry: Mocker, Stubber {
    var _spryVariable: (_calls: [RecordedCall], _stubs: [Stub]) { get set }
}

extension Spry {
    var _calls: [RecordedCall] {
        set { _spryVariable._calls = newValue }
        get { return _spryVariable._calls }
    }
    var _stubs: [Stub] {
        set { _spryVariable._stubs = newValue }
        get { return _spryVariable._stubs }
    }
}
