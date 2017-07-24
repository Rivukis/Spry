TODO: Build example project.

# Spry

[![Version](https://img.shields.io/cocoapods/v/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![License](https://img.shields.io/cocoapods/l/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![Platform](https://img.shields.io/cocoapods/p/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)

Spry is a framework that allows spying and stubbing in Apple's Swift language. Also included is a [Nimble](https://github.com/Quick/Nimble "Nimble") matcher for the spied objects.

__Table of Contents__

* [Motivation](#motivation)
* [Spryable](#spryable)
    * [Abilities](#abilities)
    * [Example Using Protocol](#example-making-a-spryable-version-of-an-object-that-has-a-protocol-interface)
    * [Example Using Inheritance](#example-making-a-spryable-version-of-an-object-by-subclassing)
* [Stubbable](#stubbable)
    * [Abilities](#abilities)
    * [Example Using Protocol](#example-making-a-stubbable-version-of-an-object-that-has-a-protocol-interface)
    * [Example Using Inheritance](#example-making-a-stubbable-version-of-an-object-by-subclassing)
    * [Example Stubbing](#example-stubbing)
* [Spyable](#spyable)
    * [Abilities](#abilities)
    * [Example Using Protocol](#example-making-a-spyable-version-of-an-object-that-has-a-protocol-interface)
    * [Example Using Inheritance](#example-making-a-spyable-version-of-an-object-by-subclassing)
    * [Example Did Call](#example-did-call)
* [Have Received Matcher](#have-received-matcher)
    * [Example Have Received](#example-have-received)
* [SpryEquatable](#spryequatable)
    * [Defaulted Conformance List](#defaulted-conformance-list)
    * [Example SpryEquatable Conformance](#example-spryEquatable-conformance)
* [Argument Enum](#argument-enum)
* [Xcode Template](#xcode-template)
    * [Template Installation](#template-installation)
* [Installation](#installation)
* [Contributors](#contributors)
* [License](#license)

## Motivation

When writing tests for a class, it is advised to only test that class's behavior and not the other objects it uses. With Swift this can be difficult.

How do you check if you are calling the correct methods at the appropriate times and passing in the appropriate arguments? Spry allows you to easily make a spy object that records every called function and the passed-in arguments.

How do you ensure that an injected object is going to return the necessary values for a given test? Spry allows you to easily make a stub object that can return a specific value.

This way you can write tests from the point of view of the class you are testing and nothing more.

## Spryable

Conform to both Stubbable and Spyable at the same time! For information about [Stubbable](#stubbable) and [Spyable](#spyable) see their respective sections below.

### Abilities

* Conform to `Spyable` and `Stubbable` at the same time.
* Reset calls and stubs at the same time with `resetCallsAndStubs()`
* Easy to implement
    * Create an object that conforms to `Spryable`
    * In every function (the ones that should be stubbed and spied) return the result of `spryify()` passing in all arguments (if any)
    * In every property (the ones that should be stubbed and spied) return the result of `stubbedValue()` in the `get {}` and use `recordCall()` in the `set {}`

### Example making a Spryable version of an object that has a protocol interface

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString(bool: Bool) -> String
    static func giveMeAString(bool: Bool) -> String
}

// The Real Class
class RealStringService: StringService {
    func giveMeAString(bool: Bool) -> String {
        // do real things
        return "string"
    }

    static func giveMeAString(bool: Bool) -> String {
        // do real things
        return "string"
    }
}

// The Fake Class
class FakeStringService: StringService, Spryable {
    enum StaticFunction: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(bool:)"
    }

    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(bool:)"
    }

    func giveMeAString(bool: Bool) -> String {
        return spryify(arguments: bool) // <-- **REQUIRED**
    }

    static func giveMeAString(bool: Bool) -> String {
        return spryify(arguments: bool) // <-- **REQUIRED**
    }
}
```

### Example making a Spryable version of an object by subclassing

Can also use inheritance where the subclass overrides all functions (the ones that should be stubbed and spied) and returning the result of `spryify()`. However, this can be problematic as it could lead to forgotten functions being NOT being overridden.

```swift
// The Real Class
class RealStringService {
    func giveMeAString(bool: Bool) -> String {
        // do real things
        return "string"
    }

    static func giveMeAString(bool: Bool) -> String {
        // do real things
        return "string"
    }
}

// The Fake Class
class FakeStringService: RealStringService, Spryable {
    enum StaticFunction: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(bool:)"
    }

    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(bool:)"
    }

    override func giveMeAString(bool: Bool) -> String {
        return spryify(arguments: bool) // <-- **REQUIRED**
    }

    override static func giveMeAString(bool: Bool) -> String {
        return spryify(arguments: bool) // <-- **REQUIRED**
    }
}
```

## Stubbable

> Conforming to Spryable will conform to Stubbable and Spyable at the same time.

### Abilities

* Stub a return value for a function on an instance of a class or the class itself using `.andReturn()`
* Stub a the implementation for a function on an instance of a class or the class itself using `.andDo()`
* Specify stubs that only get used if the right arguments are passed in using `.with()` (see [Argument Enum](#argument-enum) for alternate specifications)
* Rich `fatalError()` messages that include a detailed list of all stubbed functions when no stub is found (or the arguments received didn't pass validation)
* Reset stubs with `resetStubs()`
* Easy to implement
    * Create an object that conforms to `Stubbable`
    * In every function (the ones that should be stubbed) return the result of `stubbedValue()` passing in all arguments (if any)

> When stubbing a function that doesn't have a return value use `Void()` as the stubbed return value

### Example making a Stubbable version of an object that has a protocol interface

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String) -> Bool
    func iHaveACompletionClosure(string: String, completion: () -> Void)
    static func imAStaticFunction()
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

    static func imAStaticFunction() {
        // do real things
    }
}

// The Stub Class
class FakeStringService: StringService, Stubbable {
    enum StaticFunction: String, StringRepresentable { // <-- **REQUIRED**
        case imAStaticFunction = "imAStaticFunction()"
    }

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

    static func imAStaticFunction() {
        return stubbedValue() // <-- **REQUIRED**
    }
}
```

### Example making a Stubbable version of an object by subclassing

Can also use inheritance where the subclass overrides all functions (the ones that should be stubbed) and returning the result of `stubbedValue()`. However, this can be problematic as it could lead to forgotten functions being NOT being overridden.

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

    static func imAStaticFunction() {
        // do real things
    }
}

// The Stub Class
class FakeStringService: RealStringService, Stubbable {
    enum StaticFunction: String, StringRepresentable { // <-- **REQUIRED**
        case imAStaticFunction = "imAStaticFunction()"
    }

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

    override static func imAStaticFunction() {
        return stubbedValue() // <-- **REQUIRED**
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

// can stub static functions as well
FakeStringService.stub(.imAStaticFunction).andReturn(Void())
```

## Spyable

> Conforming to Spryable will conform to Stubbable and Spyable at the same time.

### Abilities

* Test whether a function was called or a property was set on an instance of a class or the class itself
* Specify the arguments that should have been received along with the call (see [Argument Enum](#argument-enum) for alternate specifications)
* Rich Failure messages that include a detailed list of called functions and arguments
* Reset calls with `resetCalls()`
* Easy to implement
    * Create an object that conforms to `Spyable`
    * In every function (the ones that should be spied) call `recordCall()` passing in all arguments (if any)

When using a protocol to declare the interface for an object, the compiler will tell you if/when the 'fake' doesn't conform.

### Example making a Spyable version of an object that has a protocol interface

```swift
// The Protocol
protocol StringService: class {
    func giveMeAString() -> String
    func hereAreTwoStrings(string1: String, string2: String) -> Bool
    static func imAStaticFunction()
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

    static func imAStaticFunction() {
        // do real things
    }
}

// The Spy Class
class FakeStringService: StringService, Spyable {
    enum StaticFunction: String, StringRepresentable { // <-- **REQUIRED**
        case imAStaticFunction = "imAStaticFunction()"
    }

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

    static func imAStaticFunction() {
        recordCall() // <-- **REQUIRED**
    }
}
```

### Example making a Spyable version of an object by subclassing

Can also use inheritance where the subclass overrides all functions (the ones that should be spied) and calling `recordCall()`. However, this can be problematic as it could lead to forgotten functions being NOT being overridden.

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

    static func imAStaticFunction() {
        // do real things
    }
}

// The Spy Class
class FakeStringService: RealStringService, Spyable {
    enum StaticFunction: String, StringRepresentable { // <-- **REQUIRED**
        case imAStaticFunction = "imAStaticFunction()"
    }

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

    override static func imAStaticFunction() {
        recordCall() // <-- **REQUIRED**
    }
}
```

### Example Did Call

__The Result__

```swift
// the result
let result = spyable.didCall(.functionName)

// was the function called on the fake?
result.success

// what was called on the fake?
result.recordedCallsDescription
```

__How to Use__

```swift
// passes if the function was called
fake.didCall(.functionName).success

// passes if the function was called a number of times
fake.didCall(.functionName, countSpecifier: .exactly(1)).success

// passes if the function was called at least a number of times
fake.didCall(.functionName, countSpecifier: .atLeast(1)).success

// passes if the function was called at most a number of times
fake.didCall(.functionName, countSpecifier: .atMost(1)).success

// passes if the function was called with equivalent arguments
fake.didCall(.functionName, withArguments: ["firstArg", "secondArg"]).success

// passes if the function was called with arguments that pass the specified options
fake.didCall(.functionName, withArguments: [Argument.nonNil, Argument.anything, "thirdArg"]).success

// passes if the function was called with equivalent arguments a number of times
fake.didCall(.functionName, withArguments: ["firstArg", "secondArg"], countSpecifier: .exactly(1)).success

// passes if the property was set to the right value
fake.didCall(.propertyName, with: "value").success

// passes if the static function was called
Fake.didCall(.functionName).success
```

## Have Received Matcher

Have Received Matcher is made to be used with [Nimble](https://github.com/Quick/Nimble "Nimble"). This matcher is part of a separate cocoapod called 'Spry+Nimble'. See below for installation.

All Call Matchers can be used with `to()` and `toNot()`

### Example Have Received
```swift
// passes if the function was called
expect(fake).to(haveReceived(.functionName)

// passes if the function was called a number of times
expect(fake).to(haveReceived(.functionName, countSpecifier: .exactly(1)))

// passes if the function was called at least a number of times
expect(fake).to(haveReceived(.functionName, countSpecifier: .atLeast(2)))

// passes if the function was called at most a number of times
expect(fake).to(haveReceived(.functionName, countSpecifier: .atMost(1)))

// passes if the function was called with equivalent arguments
expect(fake).to(haveReceived(.functionName, with: "firstArg", "secondArg"))

// passes if the function was called with arguments that pass the specified options
expect(fake).to(haveReceived(.functionName, with: Argument.nonNil, Argument.anything, "thirdArg")

// passes if the function was called with equivalent arguments a number of times
expect(fake).to(haveReceived(.functionName, with: "firstArg", "secondArg", countSpecifier: .exactly(1)))

// passes if the property was set to the specified value
expect(fake).to(haveReceived(.propertyName, with "value"))

// passes if the static function was called
expect(Fake).to(haveReceived(.functionName))

// passes if the static property was set
expect(Fake).to(haveReceived(.propertyName))
```

## SpryEquatable

* Spry uses `SpryEquatable` protocol to equate arguments
    * Make types conform to `SpryEquatable` using only a single line to declare conformance and by conforming to swift's `Equatable` Protocol
    * To make custom types conform to `Equatable`, see Apple's Documentation: [Equatable](https://developer.apple.com/reference/swift/equatable "Swift's Equatable")
    * NOTE: If you forget to conform to `Equatable`, the compiler will only tell you that you are not conforming to `SpryEquatable` (You should never implement methods declared in `SpryEquatable`)

### Defaulted Conformance List
* Optional (will `fatalError()` at runtime if the wrapped type does not conform to SpryEquatable)
* String
* Int
* Double
* Bool
* Array
* Dictionary
* NSObject

### Example Conforming to SpryEquatable
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

Use when the exact comparison of an argument using the `Equatable` protocol is not desired, needed, or possible.

* `case anything`
    * Used to indicate that absolutly anything passed in will be sufficient.
* `case nonNil`
    * Used to indicate that anything non-nil passed in will be sufficient.
* `case nil`
    * Used to indicate that only nil passed in will be sufficient.

## Xcode Template

A Template for creating fakes can be found in this repository in the "Templates" folder.

__Usage__

When you go to create a new file in Xcode, you will notice a new section called "Spry" with a template called "Spry Fake". Select the template, click "Next", enter the name of the type or protocol you want to fake (the word "Fake" will be added automatically), select the target(s) and folder location for the fake, and start testing!

__Template Installation__

In terminal run:
`svn export https://github.com/Rivukis/Spry/trunk/Templates/Spry ~/Library/Developer/Xcode/Templates/File\ Templates/Spry`

## Installation

Spry and Spry+Nimble are available through [CocoaPods](http://cocoapods.org). To install, simply add them your Podfile.

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
