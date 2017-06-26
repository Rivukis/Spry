public enum Argument : CustomStringConvertible, GloballyEquatable, Equatable {
    case Anything
    case NonNil
    case Nil
    case InstanceOf(type: Any.Type)

    public var description: String {
        switch self {
        case .Anything:
            return "Argument.Anything"
        case .NonNil:
            return "Argument.NonNil"
        case .Nil:
            return "Argument.Nil"
        case .InstanceOf(let type):
            return "Argument.InstanceOf(\(type))"
        }
    }

    public static func == (lhs: Argument, rhs: Argument) -> Bool {
        switch (lhs, rhs) {
        case (.Anything, .Anything):
            return true
        case (.NonNil, .NonNil):
            return true
        case (.Nil, .Nil):
            return true
        case (.InstanceOf(let a1), .InstanceOf(let b1)):
            return a1 == b1

        case (.Anything, _): return false
        case (.NonNil, _): return false
        case (.Nil, _): return false
        case (.InstanceOf(_), _): return false
        }
    }
}
