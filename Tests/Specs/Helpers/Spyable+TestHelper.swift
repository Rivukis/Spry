import Foundation
import NSpry

class SpyableTestHelper: Spyable {
    enum ClassFunction: String, StringRepresentable {
        case doClassStuff = "doClassStuff()"
        case doClassStuffWith = "doClassStuffWith(string:)"
    }

    static func doClassStuff() {
        recordCall()
    }

    static func doClassStuffWith(string: String) {
        recordCall(arguments: string)
    }

    enum Function: String, StringRepresentable {
        case ivarProperty
        case doStuff = "doStuff()"
        case doStuffWith = "doStuffWith(string:)"
        case doStuffWithWith = "doStuffWithWith(int1:int2:)"
    }

    var ivarProperty: String = "" {
        didSet {
            recordCall(arguments: ivarProperty)
        }
    }

    // This is here to show that you shouldn't try to spy on a readonly property
    var readOnlyProperty: String {
        return ""
    }

    func doStuff() {
        recordCall()
    }

    func doStuffWith(string: String) {
        recordCall(arguments: string)
    }

    func doStuffWithWith(int1: Int, int2: Int) {
        recordCall(arguments: int1, int2)
    }
}
