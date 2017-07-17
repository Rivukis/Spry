# Work in Progress

TODO: finish README.md

The framework is ready to use. Still need some clean up, documentation, and upload to cocoapods.

# Spry

[![Version](https://img.shields.io/cocoapods/v/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![License](https://img.shields.io/cocoapods/l/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![Platform](https://img.shields.io/cocoapods/p/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)

Spry is a framework that allows spying and stubbing in Apple's Swift language. Also included is a [Nimble](https://github.com/Quick/Nimble "Nimble") matcher for the spied objects.

## Spryable

Conform to both Stubbable and Spyable at the same time! For information about [Stubbable](#Stubbable) and [Spyable](#Spyable) see their respective sections below.

* Easy to implement
    * Create an object that conforms to `Spryable`
    * In every function (the ones that should be stubbed and spied) return the result of `spryify()` passing in all arguments (if any)

### Example making a Spryable version of an object that has a protocol interface

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString(bool: Bool) -> String
}

// The Real Class
class RealStringService: StringService {
    func giveMeAString(bool: Bool) -> String {
        // do real things
        return "string"
    }
}

// The Stub Class
class FakeStringService: StringService, Spryable {
    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(bool:)"
    }

    func giveMeAString(bool: Bool) -> String {
        return spryify(arguments: bool) // <-- **REQUIRED**
    }
}
```

### Example making a Spryable version of an object by subclassing

Can also use inheritance where the subclass overrides all functions (the ones that should be stubbed and spied) and returning the result of `spryify()`. However, this can problematic as it could lead to forgotten functions being overridden.

```swift
// The Real Class
class RealStringService {
    func giveMeAString(bool: Bool) -> String {
        // do real things
        return "string"
    }
}

// The Stub Class
class FakeStringService: RealStringService, Spryable {
    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(bool:)"
    }

    override func giveMeAString(bool: Bool) -> String {
        return spryify(arguments: bool) // <-- **REQUIRED**
    }
}
```

## Stubbable

> Conforming to Spryable will conform to Stubbable and Spyable at the same time.

### Abilities

* Stub a function's return value for an injected object using `.andReturn()`
* Stub a function's implementation for an injected object using `.andDo()`
* Specify stubs that only get used if the specified arguments are passed into the stubbed function using `.with()`
* Rich `fatalError()` messages that include a detailed list of all stubbed functions when no stub is found (or the arguments received didn't pass validation)
* Easy to implement
    * Create an object that conforms to `Stubbable`
    * In every function (the ones that should be stubbed) return the result of `stubbedValue()` passing in all arguments (if any)

> When stubbing a function that doesn't have a return value use `Void()` as the stubbed return value

### Example Stubbing an object that has a protocol interface

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String) -> Bool
    func iHaveACompletionClosure(string: String, completion: () -> Void)
}

// The Real Class
class RealStringService: StringService {
    func giveMeAString() -> String {
        // do real things
        return "string"
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        // do real things
        return true
    }

    func iHaveACompletionClosure(string: String, completion: () -> Void) {
        // do real things
    }
}

// The Stub Class
class FakeStringService: StringService, Stubbable {
    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString()"
        case hereAreTwoStrings = "hereAreTwoStrings(string1:string2:)"
    }

    func giveMeAString() -> String {
        return stubbedValue() // <-- **REQUIRED**
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        return stubbedValue(arguments: string1, string2) // <-- **REQUIRED**
    }

    func iHaveACompletionClosure(string: String, completion: () -> Void) {
        return stubbedValue(arguments: string, completion) // <-- **REQUIRED**
    }
}
```

### Example Stubbing an object by subclassing

Can also use inheritance where the subclass overrides all functions (the ones that should be stubbed) and returning the result of `stubbedValue()`. However, this can problematic as it could lead to forgotten functions being overridden.

```swift
// The Real Class
class RealStringService {
    func giveMeAString() -> String {
        // do real things
        return "string"
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        // do real things
        return true
    }

    func iHaveACompletionClosure(string: String, completion: () -> Void) {
        // do real things
    }
}

// The Stub Class
class FakeStringService: RealStringService, Stubbable {
    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString()"
        case hereAreTwoStrings = "hereAreTwoStrings(string1:string2:)"
    }

    override func giveMeAString() -> String {
        return stubbedValue() // <-- **REQUIRED**
    }

    override func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        return stubbedValue(arguments: string1, string2) // <-- **REQUIRED**
    }

    override func iHaveACompletionClosure(string: String, completion: () -> Void) {
        return stubbedValue(arguments: string, completion) // <-- **REQUIRED**
    }
}
```

### Example Stubbing

```swift
// will always return `"stubbed value"`
fakeStringService.stub(.hereAreTwoStrings).andReturn("stubbed value")

// specifying all arguments (will only return `true` if the arguments passed in match "first string" and "second string")
fakeStringService.stub(.hereAreTwoStrings).with("first string", "second string").andReturn(true)

// using the Arguement enum (will only return `true` if the second argument is "only this string matters")
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, "only this string matters").andReturn(true)

// using `andDo()` - Also has the ability to specify the arguments!
fakeStringService.stub(.iHaveACompletionClosure).with("correct string", Argument.anything).andDo({ arguments in
    // get the passed in argument
    let completionClosure = arguments[0] as! () -> Void

    // use the argument
    completionClosure()

    // return an appropriate value
    return Void() // <-- will be returned by the stub
})
```

## Spyable

> Conforming to Spryable will conform to Stubbable and Spyable at the same time.

### Abilities

- Test whether a function was called on an instance of a class
- Rich Failure messages that include a detailed list of called functions and arguments
- Easy to implement
    * Create an object that conforms to `Spyable`
    * In every function (the ones that should be spied) call `recordCall()` passing in all arguments (if any)

When using a protocol to declare the interface for an object, the compiler will tell you if/when the 'fake' doesn't conform.

### Example Spying an object that has a protocol interface

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String) -> Bool
}

// The Real Class
class RealStringService: StringService {
    func giveMeAString() -> String {
        // do real things
        return "string"
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        // do real things
        return true
    }
}

// The Spy Class
class FakeStringService: StringService, Spyable {
    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString()"
        case hereAreTwoStrings = "hereAreTwoStrings(string1:string2:)"
    }

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

### Example Spying an object by subclassing

Can also use inheritance where the subclass overrides all functions (the ones that should be spied) and calling `recordCall()`. However, this can problematic as it could lead to forgotten functions being overridden.

```swift

// The Real Class
class RealStringService {
    func giveMeAString() -> String {
        // do real things
        return "string"
    }

    func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        // do real things
        return true
    }
}

// The Spy Class
class FakeStringService: RealStringService, Spyable {
    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString()"
        case hereAreTwoStrings = "hereAreTwoStrings(string1:string2:)"
    }

    override func giveMeAString() -> String {
        recordCall() // <-- **REQUIRED**
        return ""
    }

    override func hereAreTwoStrings(string1: String, string2: String) -> Bool {
        recordCall(arguments: string1, string2) // <-- **REQUIRED**
        return false
    }
}
```

## Have Received Matcher

Have Received Matcher is made to be used with [Nimble](https://github.com/Quick/Nimble "Nimble"). This matcher is part of a separate cocoapod called 'Spry+Nimble'. See below for installation.

All Call Matchers can be used with `to()` and `toNot()`

### Example Tests
```swift
// passes if function was called
expect(spy).to(haveReceived(.functionName)

// passes if function was called a number of times
expect(spy).to(haveReceived(.functionName, countSpecifier: .exactly(1)))

// passes if function was called at least a number of times
expect(spy).to(haveReceived(.functionName, countSpecifier: .atLeast(2)))

// passes if function was called at most a number of times
expect(spy).to(haveReceived(.functionName, countSpecifier: .atMost(1)))

// passes if function was called with equivalent arguments
expect(spy).to(haveReceived(.functionName, with: "firstArg", "secondArg"))

// passes if function was called with arguments that pass the specified options
expect(spy).to(haveReceived(.functionName, with: Argument.nonNil, Argument.anything, "thirdArg")

// passes if function was called with equivalent arguments a number of times
expect(spy).to(haveReceived(.functionName, with: "firstArg", "secondArg", countSpecifier: .exactly(1)))
```

## SpryEquatable

* Spry uses `SpryEquatable` protocol to equate arguments
    * Make types conform to `SpryEquatable` using only a single line to declare conformance and by conforming to swift's `Equatable` Protocol
    * To make custom types conform to `Equatable`, see Apple's Documentation: [Equatable](https://developer.apple.com/reference/swift/equatable "Swift's Equatable")
    * NOTE: If you forget to conform to `Equatable`, the compiler will only tell you that you are not conforming to `SpryEquatable` (You should never implement methods declared in `SpryEquatable`)

### Spry's Default Conformance List
* Optional (will `fatalError()` ta runtime if the wrapped type does not conform to SpryEquatable)
* String
* Int
* Double
* Bool
* NSObject

### Example SpryEquatable Conformance
```swift
// custom type
extension Person: Equatable, SpryEquatable {
    public state func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name
            && lhs.age == rhs.age
    }
}

// existing type that is already Equatable
extension String: SpryEquatable {}
```

## Argument Enum

Use when the exact comparison of an argument using the `Equatable` protocol is not desired/needed.

* `case anything`
    * Used to indicate that absolutly anything passed in will be sufficient.
* `case nonNil`
    * Used to indicate that anything non-nil passed in will be sufficient.
* `case nil`
    * Used to indicate that only nil passed in will be sufficient.

## Motivation

When writing tests for a class, it is advised to only test that class's behavior and not the other objects it uses. With Swift this can be difficult.

How do you check if you are calling the correct methods at the appropriate times and passing in the appropriate arguments? Spry allows you to easily make a spy object that records every called function and the passed-in arguments.

How do you ensure that an injected object is going to return the necessary values for a given test? Spry allows you to easily make a stub object that can return a specific value.

This way you can write tests from the point of view of the class you are testing and nothing more.

## Installation

Spry is available through [CocoaPods](http://cocoapods.org). To install
it, simply add it your Podfile.

```ruby
platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target "<YOUR_TARGET>" do
    target '<YOUR_TARGET>Tests' do
        inherit! :search_paths

        pod 'Spry'

        #Uncomment the following lines to import Quick/Nimble as well as a Nimble Matcher that to test if a 'fake' has received function calls.
        #pod 'Quick'
        #pod 'Nimble'
        #pod 'Spry+Nimble'
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
