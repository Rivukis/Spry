# Work in Progress

I am in the middle of moving this matcher from a pull request to a separate repository. Right now, this only contains the two implementation files and the two test files. Turning this into an updatable framework coming soon.

# Spry

A matcher to be used with [Nimble](https://github.com/Quick/Nimble "Nimble"). This adds the ability to test whether functions have been called on stubbed objects.

# Abilities

- Test whether a function was called on an instance of a class
- Rich Failure Messages that include entire list of called functions and arguments
- All Call Matchers can be used with `to()` and `toNot()`
- Easy to implement (especially if already using protocols!)
..- Create a stub that conforms to `CallMatcher`
..- Paste in one variable declaration with a default value to conform to `CallMatcher` Protocol
..- In every function (the ones that should be recorded) call the `recordCall()` function passing in all arguments (if any)
- Currently ONLY works in swift
- Spry uses `GloballyEquatable` protocol to equate arguments
..- Make types conform to `GloballyEquatable` using only a single line to declare conformance and by conforming to swift's `Equatable` Protocol
..- To make custom types conform to `Equatable`, see Apple's Documentation: [Equatable](https://developer.apple.com/reference/swift/equatable "Swift's Equatable")
..- Compiler won't let you run tests until all arguments being tested conform to `GloballyEquatable`
..- NOTE: If you forget to conform to `Equatable`, the compiler will only tell you that you are not conforming to `GloballyEquatable` (You should never implement methods declared in `GloballyEquatable`)

## Example GloballyEquatable Conformance
```swift
extension Int : GloballyEquatable {}
extension String : GloballyEquatable {}
extension Optional : GloballyEquatable {}
```

## Example Equatable Conformance
```swift
// declare Person as Equatable
struct Person : Equatable {
var name : String
var age : Int
}

// determine how you want two Persons to equate to true/false
func ==(lhs: Person, rhs: Person) -> Bool {
let namesMatch = lhs.name == rhs.name
let agesMatch = lhs.age == rhs.age

return namesMatch && agesMatch
}
```

## Example Tests
```swift
// passes if function was called
expect(stub).to(call("functionNameWith(arg1:arg2:)"))

// passes if function was called a number of times
expect(stub).to(call("functionNameWith(arg1:arg2:)", countSpecifier: .Exactly(1)))

// passes if function was called at least a number of times
expect(stub).to(call("functionNameWith(arg1:arg2:)", countSpecifier: .AtLeast(2)))

// passes if function was called at most a number of times
expect(stub).to(call("functionNameWith(arg1:arg2:)", countSpecifier: .AtMost(1)))

// passes if function was called with equivalent arguemnts
expect(stub).to(call("functionNameWith(arg1:arg2:)", withArguments: "firstArg", "secondArg"))

// passes if function was called with arguments that pass the specified option
expect(stub).to(call("functionNameWith(arg1:arg2:arg3:)", withArguments: Arguement.Anything, Arguement.NonNil, Argument.InstanceOf(String.self)))

// passes if function was called with argument specifications a number of times
expect(stub).to(call("functionNameWith(arg1:arg2:)", withArguments: "firstArg", Argument.Anything, countSpecifier: .Exactly(2)))

// passes if function was called with argument specifications at least a number of times
expect(stub).to(call("functionNameWith(arg1:arg2:)", withArguments: "firstArg", Argument.NonNil, countSpecifier: .AtLeast(2)))

// passes if function was called with argument specifications at most a number of times
expect(stub).to(call("functionNameWith(arg1:arg2:)", withArguments: "firstArg", Argument.KindOf(type: NSObject.self), countSpecifier: .AtMost(2)))
```

Argument enum options: (use when the exact comparison of the argument using `Equatable` Protocol is not desired)
- `case Anything`
- `case NonNil`
- `case Nil`
- `case InstanceOf(type: Any.Type)`
- `case InstanceOfWith(type: Any.Type, option: ArgumentOption)`
- `case KindOf(type: AnyObject.Type)`

ArgumentOption enum for Argument.InstanceOfWith(): (used to specify whether the type passed in is optional, non-optional, or anything)
- `case Anything`
- `case NonOptional`
- `case Optional`

## Example Stub
```swift
// The Protocol
protocol StringService : class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String)
}

// The Real Class
class RealStringService : StringService {
    func giveMeAString() -> String {
        return "a real string"
    }

    func hereAreTwoStrings(string1: String, string2: String) {
        // do real stuff with strings
    }
}

// The Stub Class
class StubStringService : StringService, CallRecorder {
    var called = (functionList: [String](), argumentsList: [[Any]]()) // <-- **REQUIRED**

    func giveMeAString() -> String {
        self.recordCall() // <-- **REQUIRED**
        return "a stubbed value"
    }

    func hereAreTwoStrings(string1: String, string2: String) {
        self.recordCall(arguments: string1, string2) // <-- **REQUIRED**
    }
}
```

> Could also use inheritance with the subclass overriding all functions and replacing implementation with `self.recordCall()` functions. However, this is unadvised as it could lead to forgotten functions when adding functionality to the base class in the future.

## License

MIT License

Copyright (c) [2016] [Brian Radebaugh]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
