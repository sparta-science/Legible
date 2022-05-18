@testable import Quick

public func describe<T>(_ description: T, closure: () -> Void) {
    describe(String(describing: T.self), closure: closure)
}
public func xdescribe<T>(_ description: T, closure: () -> Void) {
    xdescribe(String(describing: T.self), closure: closure)
}
public func fdescribe<T>(_ description: T,  closure: () -> Void) {
    fdescribe(String(describing: T.self), closure: closure)
}
public func context<T>(_ description: T,  closure: () -> Void) {
    context(String(describing: T.self), closure: closure)
}
public func xcontext<T>(_ description: T, closure: () -> Void) {
    xcontext(String(describing: T.self), closure: closure)
}
public func fcontext<T>(_ description: T, closure: () -> Void) {
    fcontext(String(describing: T.self), closure: closure)
}

public var testBundle = Bundle.currentTestBundle!

public func testData(_ fileName: String) -> Data {
    try! Data(contentsOf: testBundleUrl(fileName))
}

public func testDictionary(_ fileName: String) -> NSDictionary {
    try! JSONSerialization.jsonObject(with: testData(fileName), options: .init()) as! NSDictionary
}

public func testBundleUrl(_ fileName: String) -> URL {
    testBundle.resourceURL!.appendingPathComponent(fileName)
}
