import Nimble

public func shouldNotBeCalled<T>(_ value: T, file: String = #file, line: UInt = #line) {
    fail("should not be called, but got \(value)", file: file, line: line)
}

public func shouldNotBeCalled<T>(_ value: T) {
    fail("should not be called, but got \(value)")
}
