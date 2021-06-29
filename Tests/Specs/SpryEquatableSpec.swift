import Foundation

import Quick
import Nimble
import NSpry

class SpryEquatableSpec: QuickSpec {
    override func spec() {
        describe("SpryEquatable") {
            describe("Any Objects vs Equatable") {
                context("when it is NOT Equatable and is AnyObject") {
                    let myObject1 = AnyObjectOnly()
                    let myObject2 = AnyObjectOnly()

                    it("should use pointer comparison") {
                        expect(myObject1._isEqual(to: myObject1)).to(beTrue())
                        expect(myObject1._isEqual(to: myObject2)).to(beFalse())
                    }
                }

                context("when it is Equatable and is AnyObject") {
                    let myObject1 = AnyObjectAndEquatable()
                    let myObject2 = AnyObjectAndEquatable()

                    it("should use Equatable") {
                        expect(myObject1._isEqual(to: myObject1)).to(beTrue())
                        expect(myObject1._isEqual(to: myObject2)).to(beTrue())
                    }
                }
            }

            describe("array") {
                context("when Element conforms to SpryEquatable") {
                    it("should be able to properly equate arrays") {
                        let baseArray = [1, 2, 3]

                        expect(baseArray._isEqual(to: [1, 2, 3] as SpryEquatable)).to(beTrue())

                        expect(baseArray._isEqual(to: [1, 2, 1] as SpryEquatable)).to(beFalse())
                        expect(baseArray._isEqual(to: [1, 3, 2] as SpryEquatable)).to(beFalse())
                        expect(baseArray._isEqual(to: [1, 2, 3, 4] as SpryEquatable)).to(beFalse())
                        expect(baseArray._isEqual(to: [1, 2] as SpryEquatable)).to(beFalse())
                    }
                }

                context("when Element does NOT conforms to SpryEquatable") {
                    it("should fatal error") {
                        expect {
                            let notSpryEquatable = NotSpryEquatable()
                            _ = [notSpryEquatable]._isEqual(to: [notSpryEquatable] as SpryEquatable)

                            return Void()
                        }.to(throwAssertion())
                    }
                }
            }

            describe("dictionary") {
                context("when Value conforms to SpryEquatable") {
                    it("should be able to properly equate arrays") {
                        let baseDict = [1: 1,
                                        2: 2]

                        expect(baseDict._isEqual(to: [1: 1, 2: 2] as SpryEquatable)).to(beTrue())
                        expect(baseDict._isEqual(to: [2: 2, 1: 1] as SpryEquatable)).to(beTrue())

                        expect(baseDict._isEqual(to: [1: 5, 2: 5] as SpryEquatable)).to(beFalse())
                        expect(baseDict._isEqual(to: [1: 1, 2: 2, 3: 3] as SpryEquatable)).to(beFalse())
                        expect(baseDict._isEqual(to: [1: 1] as SpryEquatable)).to(beFalse())
                    }
                }

                context("when Value does NOT conforms to SpryEquatable") {
                    it("should fatal error") {
                        expect {
                            let notSpryEquatable = NotSpryEquatable()
                            _ = [1: notSpryEquatable]._isEqual(to: [1: notSpryEquatable] as SpryEquatable)

                            return Void()
                            }.to(throwAssertion())
                    }
                }
            }

            describe("default conformers") {
                it("should contain Optional") {
                    expect("" as Any?).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain String") {
                    expect("" as String).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain Int") {
                    expect(10 as Int).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain Double") {
                    expect(10.1 as Double).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain Bool") {
                    expect(true as Bool).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain Array") {
                    expect([] as [Int]).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain Dictionary") {
                    expect([:] as [String: Any]).to(beAKindOf(SpryEquatable.self))
                }

                it("should contain NSObject") {
                    expect(NSObject()).to(beAKindOf(SpryEquatable.self))
                }
            }
        }

    }
}
