# Work in Progress

TODO: finish README.md

The framework is ready to use. Still need some clean up, documentation, and upload to cocoapods.

# Spry

[![Version](https://img.shields.io/cocoapods/v/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![License](https://img.shields.io/cocoapods/l/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![Platform](https://img.shields.io/cocoapods/p/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)

Spry is a framework that allows spying and stubbing in Apple's Swift language. Also included is a [Nimble](https://github.com/Quick/Nimble "Nimble") matcher for the spied objects.

## Stubable

### Abilities

- Stub return values for an injected object
- Specify return values that only get returned if the specified arguments are passed into the stubbed function
- Rich `fatalError()` messages that include a detailed list of all stubbed functions
- Easy to implement (especially if already using protocols!)
..- Create an object that conforms to `Stubable`
..- Paste in one variable declaration with a default value to conform to `Stubable` Protocol
..- In every function (the ones that should be stubbed) return result of the `returnValue()` function passing in all arguments (if any)

### Example Stub

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String)
}

// The Real Class
class RealStringService: StringService {
    func giveMeAString() -> String {
        return "a real string"
    }

    func hereAreTwoStrings(string1: String, string2: String) {
        // do real stuff with strings
    }
}

// The Stub Class
class StringServiceTestDouble: StringService, Stubable {
    var _stubs: [Stub] = [] // <-- **REQUIRED**

    func giveMeAString() -> String {
        return returnValue() // <-- **REQUIRED**
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        return returnValue(arguments: string1, string2) // <-- **REQUIRED**
    }
}
```

### Example Stubbing

```swift
// will always return `"stubbed value"`
stringServiceTestDouble.stub("hereAreTwoStrings(string1:string2:)").andReturn("stubbed value")

// specifying all arguments (will only return `true` if the arguments passed in match "first string" and "second string")
stringServiceTestDouble.stub("hereAreTwoStrings(string1:string2:)").with("first string", "second string").andReturn(true)

// using the Arguement enum (will only return `true` if the second argument is "only this string matters")
stringServiceTestDouble.stub("hereAreTwoStrings(string1:string2:)").with(Argument.anything, "only this string matters").andReturn(true)
```

## Spyable

### Abilities

- Test whether a function was called on an instance of a class
- Rich Failure messages that include a detailed list of called functions and arguments
- Easy to implement (especially if already using protocols!)
..- Create an object that conforms to `Spyable`
..- Paste in one variable declaration with a default value to conform to `Spyable` Protocol
..- In every function (the ones that should be recorded) call the `recordCall()` function passing in all arguments (if any)

### Example Spy
```swift
// The Protocol
protocol StringService: class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String)
}

// The Real Class
class RealStringService: StringService {
    func giveMeAString() -> String {
        return "a real string"
    }

    func hereAreTwoStrings(string1: String, string2: String) {
        // do real stuff with strings
    }
}

// The Spy Class
class StringServiceTestDouble: StringService, Spyable {
    var _calls: [RecordedCall] = [] // <-- **REQUIRED**

    func giveMeAString() -> String {
        recordCall() // <-- **REQUIRED**
        return ""
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        recordCall(arguments: string1, string2) // <-- **REQUIRED**
        return false
    }
}
```

> Could also use inheritance with the subclass overriding all functions and replacing implementation with `recordCall()` functions. However, this is unadvised as it could lead to forgotten functions when adding new functionality to the superclass in the future.

## Have Received Matcher

- All Call Matchers can be used with `to()` and `toNot()`

### Example Tests
```swift
// passes if function was called
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)"))

// passes if function was called a number of times
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)", countSpecifier: .exactly(1)))

// passes if function was called at least a number of times
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)", countSpecifier: .atLeast(2)))

// passes if function was called at most a number of times
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)", countSpecifier: .atMost(1)))

// passes if function was called with equivalent arguments
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)", withArguments: "firstArg", "secondArg"))

// passes if function was called with arguments that pass the specified option
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)", withArguments: Argument.nonNil, Argument.instanceOf(String.self)))

// passes if function was called with equivalent arguments a number of times
expect(spy).to(haveReceived("functionNameWith(arg1:arg2:)", withArguments: "firstArg", "secondArg", countSpecifier: .exactly(1)))
```

## GloballyEquatable

- Spry uses `GloballyEquatable` protocol to equate arguments
..- Make types conform to `GloballyEquatable` using only a single line to declare conformance and by conforming to swift's `Equatable` Protocol
..- To make custom types conform to `Equatable`, see Apple's Documentation: [Equatable](https://developer.apple.com/reference/swift/equatable "Swift's Equatable")
..- Compiler won't let you run tests until all arguments being tested conform to `GloballyEquatable`
..- NOTE: If you forget to conform to `Equatable`, the compiler will only tell you that you are not conforming to `GloballyEquatable` (You should never implement methods declared in `GloballyEquatable`)

### Example GloballyEquatable Conformance
```swift
extension Int : GloballyEquatable {}
extension String : GloballyEquatable {}
extension Optional : GloballyEquatable {}
```

### Example Equatable Conformance
```swift
// declare Person as Equatable
struct Person: Equatable {
    var name: String
    var age: Int
}

// determine how you want two Persons to equate to true/false
func == (lhs: Person, rhs: Person) -> Bool {
    return lhs.name == rhs.name
        && lhs.age == rhs.age
}
```

## Argument Enum

Use when the exact comparison of an argument using the `Equatable` protocol is not desired/needed.

- `case anything`
..- Used to indicate that absolutly anything passed in will be sufficient.
- `case nonNil`
..- Used to indicate that anything non-nil passed in will be sufficient.
- `case nil`
..- Used to indicate that only nil passed in will be sufficient.
- `case instanceOf(type: Any.Type)`
..- Used to indicate that anything of the given type passed in will be sufficient.
..- NOTE: `String` and `String?` (aka String and Optional<String>) are not the same type.


## Motivation

When writing tests for a class, it is advised to only test that class's behavior and not the other objects it uses. With Swift this can be difficult.

How do you check if you are calling the correct methods at the appropriate times and passing in the appropriate arguments? Spry allows you to easily make a spy object that records every called function and the passed-in arguments.

How do you ensure that an injected object is going to return the necessary values for a given test? Spry allows you to easily make a stub object that can return a specific value.

This way you can write tests from the point of view of the class you are testing and nothing more.

## Installation

Spry is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, "9.0"
use_frameworks!

target "<YOUR_TARGET>" do
    # App pods go here

    abstract_target 'Tests' do
        nherit! :search_paths
        target "<YOUR_TARGET>Tests"

        pod 'Spry'

        #Uncomment next line to get a Nimble Matcher for for spy objects (requires Quick/Nimble)
        #pod 'Spry-Nimble'
    end
end
```

## Contributors

If you have an idea that can make Spry better, please don't hesitate to submit a pull request.

## License

MIT License

Copyright (c) [2017] [Brian Radebaugh]

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
