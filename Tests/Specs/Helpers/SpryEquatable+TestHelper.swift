import Foundation
import NSpry

class SpryEquatableTestHelper: SpryEquatable {
    let isEqual: Bool
    private(set) var lastValueCompared: SpryEquatable?

    init(isEqual: Bool) {
        self.isEqual = isEqual
    }

    func _isEqual(to actual: SpryEquatable?) -> Bool {
        lastValueCompared = actual
        return isEqual
    }
}

class NotSpryEquatable { }

class AnyObjectAndEquatable: Equatable, SpryEquatable {
    public static func == (lhs: AnyObjectAndEquatable, rhs: AnyObjectAndEquatable) -> Bool {
        return true
    }
}

class AnyObjectOnly: SpryEquatable { }
