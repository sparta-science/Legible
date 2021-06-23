import Nimble
import Quick

/**
 The “ShouldNotHaveMemoryLeaks” behavior
 https://vojtastavik.com/2019/07/22/advanced-testing-using-behavior-in-quick/
 */

public class ShouldNotHaveMemoryLeaks<T>: Behavior<T> where T: AnyObject {
    public override class func spec(_ aContext: @escaping () -> T) {
        it("should be released from memory") {
            weak var weakObject: T?
            autoreleasepool {
                let object = aContext()
                weakObject = object
            }
            expect(weakObject).to(beNil(), description: "should be released but was not")
        }
    }
}

public class ShouldLeakMemory<T>: Behavior<T> where T: AnyObject {
    public override class func spec(_ aContext: @escaping () -> T) {
        it("should NOT be released from memory") {
            weak var weakObject: T?
            autoreleasepool {
                let object = aContext()
                weakObject = object
            }
            expect(weakObject).notTo(beNil(), description: "should leak memory but was released")
        }
    }
}
