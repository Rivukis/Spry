//
//  Spry.swift
//  SpryExample
//
//  Created by Brian Radebaugh on 6/27/17.
//  Copyright © 2017 Brian Radebaugh. All rights reserved.
//

protocol Spry: CallRecorder, Stubber {
    var _spryVariable: (_calls: (functionList: [String], argumentsList: [[GloballyEquatable]]), _stubs: [Stub]) { get set }
}

extension Spry {
    var _calls: (functionList: [String], argumentsList: [[GloballyEquatable]]) {
        set { _spryVariable._calls = newValue }
        get { return _spryVariable._calls }
    }
    var _stubs: [Stub] {
        set { _spryVariable._stubs = newValue }
        get { return _spryVariable._stubs }
    }
}
