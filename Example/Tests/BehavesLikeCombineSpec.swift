import Combine
import Nimble
import Quick
import Legible

class BehavesLikeCombineSpec: QuickSpec {
    override func spec() {
        describe("Built in publishers") {
            context("Just value") {
                itBehavesLike(CombinePublisher.self) {
                    Just("apple")
                        .shouldFinish(expectedValue: "apple")
                }
            }
            context("PassthroughSubject publish when send") {
                var subject: PassthroughSubject<String, Never>!
                beforeEach {
                    subject = .init()
                }
                itBehavesLike(CombinePublisher.self) {
                    subject
                        .shouldReceive(expectedValue: "banana")
                        .when(subject)
                        .sends("banana")
                }
            }
            context("CurrentValueSubject publish current value") {
                var subject: CurrentValueSubject<String, Never>!
                beforeEach {
                    subject = .init("pear")
                }
                itBehavesLike(CombinePublisher.self) {
                    subject
                        .shouldReceive(expectedValue: "pear")
                        .then {
                            expect(subject.value) == "pear"
                        }
                }
            }
            context("Empty") {
                context("finishes by default") {
                    itBehavesLike(CombinePublisher.self) {
                        Empty<Any, Never>()
                            .shouldFinish()
                    }
                }
                context("never publishes") {
                    itBehavesLike(CombinePublisher.self) {
                        Empty<Any, Never>(completeImmediately: false)
                            .shouldNotReceive()
                    }
                }
            }
            context("Fail finishes with error") {
                enum TestFailure: Error, Equatable {
                    case example
                }
                itBehavesLike(CombinePublisher.self) {
                    Fail<Any,TestFailure>(error: .example)
                        .shouldFail(with: TestFailure.example)
                }
            }
            context("Sequence publishes all by one and finishes") {
                itBehavesLike(CombinePublisher.self) {
                    Publishers.Sequence<[Int], Never>(sequence: [1,2,3])
                        .collect(3)
                        .shouldFinish {
                            expect($0) == [1,2,3]
                        }
                }
            }
        }
    }
}
