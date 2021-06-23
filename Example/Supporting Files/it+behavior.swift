import Quick

/**
 Custom overload of it which takes Behavior as a parameter.
 https://vojtastavik.com/2019/07/22/advanced-testing-using-behavior-in-quick/
 It allows to be more flexible in naming Behaviors.
 https://github.com/Quick/Quick/pull/907
 */

public func it<C>(
    _ behavior: Quick.Behavior<C>.Type,
    _ description: String = "",
    file: FileString = #file,
    line: UInt = #line,
    context: @escaping () -> C
) {
    itBehavesLike(behavior, file: file, line: line, context: context)
}

public func fit<C>(
    _ behavior: Quick.Behavior<C>.Type,
    _ description: String = "",
    file: FileString = #file,
    line: UInt = #line,
    context: @escaping () -> C
) {
    fitBehavesLike(behavior, file: file, line: line, context: context)
}

public func xit<C>(
    _ behavior: Quick.Behavior<C>.Type,
    _ description: String = "",
    file: FileString = #file,
    line: UInt = #line,
    context: @escaping () -> C
) {
    xitBehavesLike(behavior, file: file, line: line, context: context)
}
