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

public extension Publisher where Self.Failure: Error {
    func shouldFail<T: Error & Equatable>(expectedError: T,
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
                      _ execute: (() -> Void)? = nil,
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
                execute?()
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
    func shouldFinish(_ execute: (() -> Void)? = nil) -> CombineExpectation {
        expecting { expectation in
            sink(receiveCompletion: { completion in
                if case .finished = completion {
                    execute?()
                    expectation.fulfill()
                } else {
                    fail("unexpected \(completion)")
                }
            }, receiveValue: shouldNotBeCalled(_:))
        }
    }
    func shouldReceive(_ execute: (() -> Void)? = nil,
                       file: String = #file,
                       line: UInt = #line) -> CombineExpectation where Output == Void {
        expecting { expectation in
            sink(receiveCompletion: shouldNotBeCalled(_:)) { value in
                expect(file: file, line: line, value) == Void()
                execute?()
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
    func whenFinished(afterReceiving: @escaping (Output) -> Void,
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
}

public struct CombineAction {
    var expecting: CombineExpectation
    var action: (() -> Void)?
    var timeout: TimeInterval
}

public extension CombineExpectation {
    var immediately: CombineAction {
        before(timeout: 0)
    }

    func before(timeout: TimeInterval) -> CombineAction {
        when(timeout: timeout)
    }

    func when(_ execute: (() -> Void)? = nil, timeout: TimeInterval = 0) -> CombineAction {
        CombineAction(expecting: self, action: execute, timeout: timeout)
    }

    func when<S: Subject>(_ publisher: S, sends value: S.Output, _ execute: (() -> Void)? = nil) -> CombineAction {
        when {
            publisher.send(value)
            execute?()
        }
    }
    func when<S: Subject>(_ publisher: S, completesWith error: S.Failure) -> CombineAction {
        when { publisher.send(completion: .failure(error)) }
    }
    func whenFinished<S: Publisher>(_ publisher: S) -> CombineAction {
        when {
            let cancellable = publisher.sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    fail("finished with error: \(error)")
                }
            }, receiveValue: shouldNotBeCalled(_:))
            expect(cancellable).notTo(beNil())
        }
    }
}

public class BehavesLikeCombine: Behavior<CombineAction> {
    public override class func spec(_ aContext: @escaping () -> CombineAction) {
        context("stream of events") {
            var inContext: CombineAction!
            var expectation: XCTestExpectation!
            beforeEach {
                inContext = aContext()
                expectation = inContext.expecting.expectation
            }
            it("should fullfil expectations") {
                inContext.action?()
                if .completed != XCTWaiter().wait(for: [expectation],
                                                  timeout: inContext.timeout) {
                    fail(expectation.expectationDescription)
                }
                inContext.expecting.cancellable.cancel()
            }
        }
    }
}

public class CombinePublisher: BehavesLikeCombine {}
