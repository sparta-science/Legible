import Combine
import Nimble
import Quick
import XCTest

public struct CombineExpectation {
    var cancellable: AnyCancellable
    var expectation: XCTestExpectation
}

private typealias CombineAsync = (_ expectation: XCTestExpectation) -> AnyCancellable

// swiftlint:disable:next function_default_parameter_at_end
private func expecting(name: String = #function,
                       block: CombineAsync) -> CombineExpectation {
    let expectation = XCTestExpectation(
        description: name + " has failed"
    )
    return CombineExpectation(cancellable: block(expectation),
                              expectation: expectation)
}

public extension Publisher {
    func shouldFail<T: Error & Equatable>(with expectedError: T,
                                          _ execute: (() -> Void)? = nil,
                                          file: String = #file,
                                          line: UInt = #line) -> CombineExpectation {
        expecting { expectation in
            sink(receiveCompletion: { complete in
                if case .failure(let error) = complete {
                    execute?()
                    expect(error).to(matchError(expectedError))
                    expectation.fulfill()
                } else {
                    fail("got finished intead of failure with \(expectedError)", file: file, line: line)
                }
            }, receiveValue: shouldNotBeCalled(_:))
        }
    }
}
public extension Publisher where Self.Output: Equatable {
    func shouldFinish(expectedValue: Output,
                      file: String = #file,
                      line: UInt = #line) -> CombineExpectation {
        expecting { expectation in
            sink {
                if case .finished = $0 {
                    expectation.fulfill()
                } else {
                    fail("complete with failure \($0) instead of finish", file: file, line: line)
                }
            } receiveValue: { value in
                expect(value) == expectedValue
            }
        }
    }
    func shouldReceive(expectedValue: Output,
                       _ execute: (() -> Void)? = nil) -> CombineExpectation where Output: Equatable {
        expecting { expectation in
            sink(receiveCompletion: shouldNotBeCalled(_:)) { value in
                expect(value) == expectedValue
                execute?()
                expectation.fulfill()
            }
        }
    }
}

public extension Publisher {
    func shouldFinish() -> CombineExpectation {
        expecting { expectation in
            sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                } else {
                    fail("unexpected \(completion)")
                }
            }, receiveValue: shouldNotBeCalled(_:))
        }
    }
    func shouldReceive(file: String = #file,
                       line: UInt = #line) -> CombineExpectation where Output == Void {
        expecting { expectation in
            sink(receiveCompletion: shouldNotBeCalled(_:)) { value in
                expect(file: file, line: line, value) == Void()
                expectation.fulfill()
            }
        }
    }
    func shouldNotReceive() -> CombineExpectation {
        expecting { expectation in
            expectation.fulfill()
            return sink(receiveCompletion: shouldNotBeCalled(_:),
                        receiveValue: shouldNotBeCalled(_:))
        }
    }
    func shouldReceive(numberOfTimes: Int) -> CombineExpectation {
        expecting { expectation in
            expectation.expectedFulfillmentCount = numberOfTimes
            return sink(receiveCompletion: shouldNotBeCalled(_:)) { _ in
                expectation.fulfill()
            }
        }
    }
    func shouldFinish(afterReceiving: @escaping (Output) -> Void,
                      file: String = #file,
                      line: UInt = #line) -> CombineExpectation {
        expecting { expectation in
            sink(receiveCompletion: {
                if case .finished = $0 {
                    expectation.fulfill()
                } else {
                    fail("unexpected \($0)", file: file, line: line)
                }
            }, receiveValue: afterReceiving)
        }
    }
    func shouldFinishAfterReceivingVoid(file: String = #file,
                                  line: UInt = #line) -> CombineExpectation where Output == Void {
        shouldFinish {
            expect(file: file, line: line, $0) == Void()
        }
    }
}

public struct CombineAction {
    var waiting: CombineTimelyExpectation
    var action: (() -> Void)?
    var finally: (() -> Void)?

    public func then(_ execute: @escaping () -> Void) -> CombineAction {
        CombineAction(waiting: waiting, action: action, finally: execute)
    }
}

public struct CombineTimelyExpectation {
    var expecting: CombineExpectation
    var timeout: TimeInterval

    public func when(_ execute: (() -> Void)? = nil) -> CombineAction {
        CombineAction(waiting: self, action: execute)
    }
    public func when<S: Publisher>(_ publisher: S) -> WhenPublisher<S> {
        WhenPublisher(publisher: publisher, expectation: self)
    }
    public func then(_ execute: @escaping () -> Void) -> CombineAction {
        CombineAction(waiting: self, action: nil, finally: execute)
    }
}

public extension CombineExpectation {
    internal var immediately: CombineTimelyExpectation {
        before(timeout: 0)
    }

    func before(timeout: TimeInterval) -> CombineTimelyExpectation {
        CombineTimelyExpectation(expecting: self, timeout: timeout)
    }

    func when(_ execute: (() -> Void)? = nil) -> CombineAction {
        immediately.when(execute)
    }
    func when<S: Publisher>(_ publisher: S) -> WhenPublisher<S> {
        immediately.when(publisher)
    }
    func then(_ execute: @escaping () -> Void) -> CombineAction {
        immediately.then(execute)
    }
}

public struct WhenPublisher<P> where P: Publisher {
    let publisher: P
    let expectation: CombineTimelyExpectation

    internal init(publisher: P, expectation: CombineTimelyExpectation) {
        self.publisher = publisher
        self.expectation = expectation
    }

    public var finishes: CombineAction {
        expectation.when {
            let cancellable = publisher.sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    fail("finished with error: \(error)")
                }
            }, receiveValue: shouldNotBeCalled(_:))
            expect(cancellable).notTo(beNil())
        }
    }
}

extension WhenPublisher where P: Subject {
    public func sends(_ value: P.Output) -> CombineAction {
        expectation.when {
            publisher.send(value)
        }
    }
    public func fails(with error: P.Failure) -> CombineAction {
        expectation.when {
            publisher.send(completion: .failure(error))
        }
    }
}

internal class BehavesLikeCombineChain: Behavior<CombineAction> {
    public override class func spec(_ aContext: @escaping () -> CombineAction) {
        context("stream of events") {
            var inContext: CombineAction!
            var expectation: XCTestExpectation!
            beforeEach {
                inContext = aContext()
                expectation = inContext.waiting.expecting.expectation
            }
            it("should fullfil expectations") {
                inContext.action?()
                if .completed != XCTWaiter().wait(for: [expectation],
                                                  timeout: inContext.waiting.timeout) {
                    fail(expectation.expectationDescription)
                }
                inContext.waiting.expecting.cancellable.cancel()
                inContext.finally?()
            }
        }
    }
}

public class BehavesLikeCombine<T>: Behavior<T> {
    public override class func spec(_ aContext: @escaping () -> T) {
        if let action = aContext as? () -> CombineAction {
            BehavesLikeCombineChain.spec(action)
        } else if let expectation = aContext as? () -> CombineTimelyExpectation {
            BehavesLikeCombineChain.spec {
                expectation().when()
            }
        } else if let expectation = aContext as? () -> CombineExpectation {
            BehavesLikeCombineChain.spec {
                expectation().immediately.when()
            }
        }
    }
}

public class CombinePublisher<T>: BehavesLikeCombine<T> {}
