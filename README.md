TODO: Build example project.

# Spry

[![Version](https://img.shields.io/cocoapods/v/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![License](https://img.shields.io/cocoapods/l/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)
[![Platform](https://img.shields.io/cocoapods/p/Spry.svg?style=flat)](http://cocoapods.org/pods/Spry)

Spry is a framework that allows spying and stubbing in Apple's Swift language. Also included is a [Nimble](https://github.com/Quick/Nimble "Nimble") matcher for the spied objects.

__Table of Contents__

* [Motivation](#motivation)
* [Spryable](#spryable)
    * [Example](#spryable-example)
* [Stubbable](#stubbable)
    * [Stubbable Example](#stubbable-example)
    * [Stubbing Example](#stubbing-example)
* [Spyable](#spyable)
    * [Spyable Example](#spyable-example)
    * [Did Call Example](#did-call-example)
* [Have Received Matcher](#have-received-matcher)
    * [Have Received Example](#have-received-example)
* [SpryEquatable](#spryequatable)
    * [SpryEquatable Conformance Example](#spryequatable-conformance-example)
* [ArgumentEnum](#argumentenum)
* [ArgumentCaptor](#argumentcaptor)
    * [ArgumentCaptor Example](#argumentcaptor-example)
* [Xcode Templates](#xcode-template)
* [Installation](#installation)
* [Contributing](#contributing)
* [License](#license)

## Motivation

When writing tests for a class, it is advised to only test that class's behavior and not the other objects it uses. With Swift this can be difficult.

How do you check if you are calling the correct methods at the appropriate times and passing in the appropriate arguments? Spry allows you to easily make a spy object that records every called function and the passed-in arguments.

How do you ensure that an injected object is going to return the necessary values for a given test? Spry allows you to easily make a stub object that can return a specific value.

This way you can write tests from the point of view of the class you are testing (the subject under test) and nothing more.

## Spryable

Conform to both Stubbable and Spyable at the same time! For information about [Stubbable](#stubbable) and [Spyable](#spyable) see their respective sections below.

__Abilities__

* Conform to `Spyable` and `Stubbable` at the same time.
* Reset calls and stubs at the same time with `resetCallsAndStubs()`
* Easy to implement
    * Create an object that conforms to `Spryable`
    * In every function (the ones that should be stubbed and spied) return the result of `spryify()` passing in all arguments (if any)
        * also works for special functions like `subscript`
    * In every property (the ones that should be stubbed and spied) return the result of `stubbedValue()` in the `get {}` and use `recordCall()` in the `set {}`

### Spryable Example

```swift
// The Real Thing can be a protocol
protocol StringService: class {
    var readonlyProperty: String { get }
    var readwriteProperty: String { set get }
    func doThings()
    func giveMeAString(arg1: Bool, arg2: String) -> String
    class func giveMeAString(arg1: Bool, arg2: String) -> String
}

// The Real Thing can be a class
class StringService {
    var readonlyProperty: String {
        return ""
    }

    var readwriteProperty: String = ""

    func doThings() {
        // do real things
    }

    func giveMeAString(arg1: Bool, arg2: String) -> String {
        // do real things
        return ""
    }

    class func giveMeAString(arg1: Bool, arg2: String) -> String {
        // do real things
        return ""
    }
}

// The Fake Class (If the fake is from a class then `override` will be required for each function and property)
class FakeStringService: StringService, Spryable {
    enum ClassFunction: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(arg1:arg2:)"
    }

    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case readonlyProperty = "readonlyProperty"
        case readwriteProperty = "readwriteProperty"
        case doThings = "doThings()"
        case giveMeAString = "giveMeAString(arg1:arg2:)"
    }

    var readonlyProperty: String {
        return stubbedValue()
    }

    var readwriteProperty: String {
        set {
            recordCall(arguments: newValue)
        }
        get {
            return stubbedValue()
        }
    }

    func doThings() {
        return spryify() // <-- **REQUIRED**
    }

    func giveMeAString(arg1: Bool, arg2: String) -> String {
        return spryify(arguments: arg1, arg2) // <-- **REQUIRED**
    }

    class func giveMeAString(arg1: Bool, arg2: String) -> String {
        return spryify(arguments: arg1, arg2) // <-- **REQUIRED**
    }
}
```

## Stubbable

_Spryable conforms to Stubbable.

__Abilities__

* Stub a return value for a function on an instance of a class or the class itself using `.andReturn()`
* Stub the implementation for a function on an instance of a class or the class itself using `.andDo()`
    * `.andDo()` takes in a closure that passes in an `Array` containing the parameters and should return the stubbed value
* Specify stubs that only get used if the right arguments are passed in using `.with()` (see [Argument Enum](#argument-enum) for alternate specifications)
* Rich `fatalError()` messages that include a detailed list of all stubbed functions when no stub is found (or the arguments received didn't pass validation)
* Reset stubs with `resetStubs()`

### Stubbing Example

```swift
// will always return `"stubbed value"`
fakeStringService.stub(.hereAreTwoStrings).andReturn("stubbed value")

// defaults to return Void()
fakeStringService.stub(.hereAreTwoStrings).andReturn()

// specifying all arguments (will only return `true` if the arguments passed in match "first string" and "second string")
fakeStringService.stub(.hereAreTwoStrings).with("first string", "second string").andReturn(true)

// using the Arguement enum (will only return `true` if the second argument is "only this string matters")
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, "only this string matters").andReturn(true)

// using custom validation
let customArgumentValidation = Argument.pass({ actualArgument -> Bool in
    let passesCustomValidation = // ...
    return passesCustomValidation
})
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, customArgumentValidation).andReturn("stubbed value")

// using argument captor
let captor = Argument.captor()
fakeStringService.stub(.hereAreTwoStrings).with(Argument.nonNil, captor).andReturn("stubbed value")
captor.getValue(as: String.self) // gets the second argument the first time this function was called where the first argument was also non-nil.
captor.getValue(at: 1, as: String.self) // // gets the second argument the second time this function was called where the first argument was also non-nil.

// using `andDo()` - Also has the ability to specify the arguments!
fakeStringService.stub(.iHaveACompletionClosure).with("correct string", Argument.anything).andDo({ arguments in
    // get the passed in argument
    let completionClosure = arguments[0] as! () -> Void

    // use the argument
    completionClosure()

    // return an appropriate value
    return Void() // <-- will be returned by the stub
})

// can stub class functions as well
FakeStringService.stub(.imAClassFunction).andReturn(Void())

// do not forget to reset class stubs (since Class objects are essentially singletons)
FakeStringService.resetStubs()
```

## Spyable

_Spryable conforms to Spyable.

__Abilities__

* Test whether a function was called or a property was set on an instance of a class or the class itself
* Specify the arguments that should have been received along with the call (see [Argument Enum](#argument-enum) for alternate specifications)
* Rich Failure messages that include a detailed list of called functions and arguments
* Reset calls with `resetCalls()`

### Spyable Example

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

// passes if the function was called with an argument that passes the custom validation
let customArgumentValidation = Argument.pass({ argument -> Bool in
    let passesCustomValidation = // ...
    return passesCustomValidation
})
fake.didCall(.functionName, withArguments: [customArgumentValidation]).success

// passes if the function was called with equivalent arguments a number of times
fake.didCall(.functionName, withArguments: ["firstArg", "secondArg"], countSpecifier: .exactly(1)).success

// passes if the property was set to the right value
fake.didCall(.propertyName, with: "value").success

// passes if the class function was called
Fake.didCall(.functionName).success
```

## Have Received Matcher

Have Received Matcher is made to be used with [Nimble](https://github.com/Quick/Nimble "Nimble"). This matcher is part of a separate cocoapod called 'Spry+Nimble'. See below for installation.

All Call Matchers can be used with `to()`, `toNot()`, `toEventually()`, and `toEventuallyNot()`

### Have Received Example
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
expect(fake).to(haveReceived(.functionName, with: Argument.nonNil, Argument.anything, "thirdArg"))

// passes if the function was called with an argument that passes the custom validation
let customArgumentValidation = Argument.pass({ argument -> Bool in
    let passesCustomValidation = // ...
    return passesCustomValidation
})
expect(fake).to(haveReceived(.functionName, with: customArgumentValidation))

// passes if the function was called with equivalent arguments a number of times
expect(fake).to(haveReceived(.functionName, with: "firstArg", "secondArg", countSpecifier: .exactly(1)))

// passes if the property was set to the specified value
expect(fake).to(haveReceived(.propertyName, with "value"))

// passes if the class function was called
expect(Fake).to(haveReceived(.functionName))

// passes if the class property was set
expect(Fake).to(haveReceived(.propertyName))

// do not forget to reset calls on class objects (since Class objects are essentially singletons)
Fake.resetCalls()
```

## SpryEquatable

Spry uses `SpryEquatable` protocol to equate arguments

* Make types conform to `SpryEquatable` using only a single line to declare conformance and one of the following
    * Be AnyObject
        * all `class`s are `AnyObject`
        * `enum`s and `struct`s are NOT `AnyObject`
    * Conform to swift's `Equatable` Protocol
        * To make custom types conform to `Equatable`, see Apple's Documentation: [Equatable](https://developer.apple.com/reference/swift/equatable "Swift's Equatable")
        * NOTE: If you forget to conform to `Equatable`, the compiler will only tell you that you are not conforming to `SpryEquatable` (You should never implement methods declared in `SpryEquatable`)
* NOTE: Object's, that are both `AnyObject` and conform to `Equatable`, will use `Equatable`'s' `==(lhs:rhs:)` function and not pointer comparision.

__Defaulted Conformance List__

* Optional (will `fatalError()` at runtime if the wrapped type does not conform to SpryEquatable)
* String
* Int
* Double
* Bool
* Array
* Dictionary
* NSObject

### SpryEquatable Conformance Example
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

[AutoEquatable](https://github.com/Rivukis/AutoEquatable) is a library to automatically conform to Equatable which turns the above into.

```swift
extension Person: AutoEquatable, SpryEquatable { }
```

## ArgumentEnum

Use when the exact comparison of an argument using the `Equatable` protocol is not desired, needed, or possible.

* `case anything`
    * Used to indicate that absolutely anything passed in will be sufficient.
* `case nonNil`
    * Used to indicate that anything non-nil passed in will be sufficient.
* `case nil`
    * Used to indicate that only nil passed in will be sufficient.
* `case pass((Any?) -> Bool)`
    * Used to provide custom validation for a specific argument.
    * The associated value is a closure which takes in the argument and returns a bool to indicate whether or not it passed validation.
* `func captor() -> ArgumentCaptor`
    * Used to create a new [ArgumentCaptor](#argumentcaptor)
    * An argument captor is used to capture arguments as the function is called so that they can be accessed at a later point.

## ArgumentCaptor

ArgumentCaptor is used to capture a specific argument when the stubbed function is called. Afterward the captor can serve up the captured argument for custom argument checking. An ArgumentCaptor will capture the specified argument every time the stubbed function is called.

Captured arguments are stored in chronological order for each function call. When getting an argument you can specify which argument to get (defaults to the first time the function was called)

When getting a captured argument the type must be specified. If the argument can not be cast as the type given then a `fatalError()` will occur.

### ArgumentCaptor Example:

```swift
let captor = Argument.captor()
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, captor).andReturn("stubbed value")

_ = fakeStringService.hereAreTwoStrings(string1: "first arg first call", string2: "second arg first call")
_ = fakeStringService.hereAreTwoStrings(string1: "first arg second call", string2: "second arg second call")

let secondArgFromFirstCall = captor.getValue(as: String.self) // `at:` defaults to `0` or first call
let secondArgFromSecondCall = captor.getValue(at: 1, as: String.self)
```

## Xcode Templates

Templates for creating fakes can be found in this repository in the "Templates" folder.

__Usage__

When you go to create a new file in Xcode, you will notice a new section called "Spry" with templates called "Class Fake" and "Protocol Fake". Select the template according to the type being faked, click "Next", enter the name of the type or protocol you want to fake (the word "Fake" will be added automatically), select the target(s) and folder location for the fake, and start testing with ease!

__Template Installation__

In terminal run the following command:

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

        #Uncomment the following lines to import Quick/Nimble as well as a Nimble Matcher used to test if a 'fake' has received function calls.
        #pod 'Quick'
        #pod 'Nimble'
        #pod 'Spry+Nimble'
    end
end
```

## Contributing

If you have an idea that can make Spry better, please don't hesitate to submit a pull request!

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
