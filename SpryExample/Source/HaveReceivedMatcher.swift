import Nimble

public func haveReceived(_ function: String, with arguments: GloballyEquatable..., countSpecifier: CountSpecifier = .atLeast(1)) -> Predicate<Mocker> {
    return Predicate.define("") { actualExpression, msg in
        guard let mocker = try actualExpression.evaluate() else {
            let descriptionOfAttempted = descriptionOfNilAttempt(arguments: arguments, countSpecifier: countSpecifier)
            return PredicateResult(bool: false, message: .expectedActualValueTo(descriptionOfAttempted))
        }

        let descriptionOfAttempted = descriptionOfExpectation(actual: mocker, function: function, arguments: arguments, countSpecifier: countSpecifier)
        let result = mocker.didCall(function: function, withArguments: arguments, countSpecifier: countSpecifier)

        return PredicateResult(bool: result.success, message: .expectedCustomValueTo(descriptionOfAttempted, result.recordedCallsDescription))
    }
}

// MARK: Private

private func descriptionOfExpectation(actual: Mocker, function: String, arguments: [GloballyEquatable], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive <\(function)> on <\(type(of: actual))>"

    if !arguments.isEmpty {
        let argumentsDescription = arguments.map{ "<\($0)>" }.joined(separator: ", ")
        descriptionOfAttempt += " with \(argumentsDescription)"
    }

    let countDescription: String
    let count: Int
    switch countSpecifier {
    case .exactly(let _count):
        countDescription = "exactly"
        count = _count
    case .atLeast(let _count) where _count != 1:
        countDescription = "at least"
        count = _count
    case .atMost(let _count):
        countDescription = "at most"
        count = _count
    default:
        countDescription = ""
        count = -1
    }

    if !countDescription.isEmpty {
        let pluralism = count == 1 ? "" : "s"
        descriptionOfAttempt += " \(countDescription) \(count) time\(pluralism)"
    }

    return descriptionOfAttempt
}

private func descriptionOfNilAttempt(arguments: [GloballyEquatable], countSpecifier: CountSpecifier) -> String {
    var descriptionOfAttempt = "receive function"

    if arguments.count != 0 {
        descriptionOfAttempt += " with arguments"
    }

    switch countSpecifier {
    case .exactly(_):
        descriptionOfAttempt += " 'count' times"
    case .atLeast(let count) where count != 1:
        descriptionOfAttempt += " at least 'count' times"
    case .atMost(_):
        descriptionOfAttempt += " at most 'count' times"
    default: break
    }

    return descriptionOfAttempt
}
