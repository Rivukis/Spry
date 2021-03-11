import XCTest
import Quick

QCKMain([StubbableSpec.self,
         ArgumentSpec.self,
         HaveReceivedMatcherSpec.self,
         HaveRecordedCallsMatcherSpec.self,
         SpryableSpec.self,
         SpryEquatableSpec.self,
         SpyableSpec.self])
