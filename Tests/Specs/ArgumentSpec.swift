import Foundation
import Quick
import Nimble

@testable import NSpry

class ArgumentSpec: QuickSpec {
    override func spec() {
        describe("Argument") {
            describe("CustomStringConvertible") {
                it("should return the correct description for each case") {
                    expect("\(Argument.anything)").to(equal("Argument.anything"))
                    expect("\(Argument.nonNil)").to(equal("Argument.nonNil"))
                    expect("\(Argument.nil)").to(equal("Argument.nil"))
                    expect("\(Argument.validator({ _ in true }))").to(equal("Argument.validator"))
                }
            }

            describe("is equal args list") {
                var subjectActionRanCount: Int!
                var result: Bool!
                var specifiedArgs: [SpryEquatable?]!
                var actualArgs: [Any?]!

                beforeEach {
                    result = nil
                    specifiedArgs = nil
                    actualArgs = nil
                    subjectActionRanCount = 0
                }

                let subjectAction: () -> Void = {
                    subjectActionRanCount = subjectActionRanCount + 1
                    result = isEqualArgsLists(fakeType: Any.self, functionName: "", specifiedArgs: specifiedArgs, actualArgs: actualArgs)
                }

                afterEach {
                    guard subjectActionRanCount == 1 else {
                        fatalError()
                    }
                }

                context("when the args lists have different counts") {
                    beforeEach {
                        specifiedArgs = []
                        actualArgs = [1]
                    }

                    it("should fatal error") {
                        expect {
                            subjectAction()
                        }.to(throwAssertion())
                    }
                }

                describe("Argument enum") {
                    describe(".anything") {
                        beforeEach {
                            specifiedArgs = [
                                Argument.anything,
                                Argument.anything,
                                Argument.anything,
                            ]
                            actualArgs = [
                                "asdf",
                                3 as Int?,
                                NSObject(),
                            ]

                            subjectAction()
                        }

                        it("should always return true") {
                            expect(result).to(beTrue())
                        }
                    }

                    describe(".nonNil") {
                        context("when the actual arg is nil") {
                            beforeEach {
                                specifiedArgs = [
                                    Argument.nonNil,
                                ]
                                actualArgs = [
                                    nil as String?,
                                ]

                                subjectAction()
                            }

                            it("should return false") {
                                expect(result).to(beFalse())
                            }
                        }

                        context("when the actual arg is not nil") {
                            beforeEach {
                                specifiedArgs = [
                                    Argument.nonNil,
                                ]
                                actualArgs = [
                                    "" as String?,
                                ]

                                subjectAction()
                            }

                            it("should return true") {
                                expect(result).to(beTrue())
                            }
                        }
                    }

                    describe(".nil") {
                        context("when the actual arg is nil") {
                            beforeEach {
                                specifiedArgs = [
                                    Argument.nil,
                                    Argument.nil,
                                ]
                                actualArgs = [
                                    nil as String?,
                                    nil as Int?,
                                ]

                                subjectAction()
                            }

                            it("should return true") {
                                expect(result).to(beTrue())
                            }
                        }

                        context("when the actual arg is not nil") {
                            beforeEach {
                                specifiedArgs = [
                                    Argument.nil,
                                ]
                                actualArgs = [
                                    "" as String?,
                                ]

                                subjectAction()
                            }

                            it("should return false") {
                                expect(result).to(beFalse())
                            }
                        }
                    }

                    describe(".validator") {
                        describe("validating closure") {
                            var passedInArg: String!
                            let actualArg = "actual arg"

                            beforeEach {
                                passedInArg = nil

                                let customValidator = Argument.validator { actualArg -> Bool in
                                    passedInArg = actualArg as? String
                                    return true
                                }

                                specifiedArgs = [
                                    customValidator,
                                ]
                                actualArgs = [
                                    actualArg,
                                ]

                                subjectAction()
                            }

                            it("should be passed the actual arg") {
                                expect(passedInArg).to(equal(actualArg))
                            }
                        }

                        context("when the validator returns true") {
                            beforeEach {
                                specifiedArgs = [
                                    Argument.validator { _ -> Bool in
                                        return true
                                    },
                                ]
                                actualArgs = [
                                    "",
                                ]

                                subjectAction()
                            }

                            it("should return true") {
                                expect(result).to(beTrue())
                            }
                        }

                        context("when the validator returns true") {
                            beforeEach {
                                specifiedArgs = [
                                    Argument.validator { _ -> Bool in
                                        return false
                                    },
                                ]
                                actualArgs = [
                                    "",
                                ]

                                subjectAction()
                            }

                            it("should return false") {
                                expect(result).to(beFalse())
                            }
                        }
                    }
                }

                describe("ArgumentCaptor") {
                    beforeEach {
                        specifiedArgs = [
                            Argument.captor(),
                            ArgumentCaptor(),
                        ]
                        actualArgs = [
                            "",
                            "",
                        ]

                        subjectAction()
                    }

                    it("should always return true") {
                        expect(result).to(beTrue())
                    }
                }

                describe("passing in nil") {
                    context("when both arguments are nil (of any type)") {
                        beforeEach {
                            specifiedArgs = [
                                nil as Int?,
                            ]
                            actualArgs = [
                                nil as String?,
                            ]

                            subjectAction()
                        }

                        it("should return true") {
                            expect(result).to(beTrue())
                        }
                    }

                    context("when the specified argument is nil (of any type)") {
                        beforeEach {
                            specifiedArgs = [
                                nil as Int?,
                            ]
                            actualArgs = [
                                "",
                            ]

                            subjectAction()
                        }

                        it("should return false") {
                            expect(result).to(beFalse())
                        }
                    }

                    context("when the actual argument is nil (of any type)") {
                        beforeEach {
                            specifiedArgs = [
                                "",
                            ]
                            actualArgs = [
                                nil as Int?,
                            ]

                            subjectAction()
                        }

                        it("should return false") {
                            expect(result).to(beFalse())
                        }
                    }
                }

                describe("actual arg equatability") {
                    context("when the actual arg is NOT SpryEquatable") {
                        beforeEach {
                            specifiedArgs = [
                                "",
                            ]
                            actualArgs = [
                                NotSpryEquatable(),
                            ]
                        }

                        it("should fatal error") {
                            expect {
                                subjectAction()
                            }.to(throwAssertion())
                        }
                    }

                    context("when the actual arg is SpryEquatable; NOT equal to specified") {
                        beforeEach {
                            specifiedArgs = [
                                SpryEquatableTestHelper(isEqual: false),
                            ]
                            actualArgs = [
                                SpryEquatableTestHelper(isEqual: false),
                            ]

                            subjectAction()
                        }

                        it("should return false") {
                            expect(result).to(beFalse())
                        }
                    }

                    context("when the actual arg is SpryEquatable; equal to specified") {
                        beforeEach {
                            specifiedArgs = [
                                SpryEquatableTestHelper(isEqual: true),
                            ]
                            actualArgs = [
                                SpryEquatableTestHelper(isEqual: true),
                            ]

                            subjectAction()
                        }

                        it("should return true") {
                            expect(result).to(beTrue())
                        }
                    }
                }
            }
        }

    }
}
