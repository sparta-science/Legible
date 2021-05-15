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
                        .immediately
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
                        .when(subject, sends: "banana")
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
                        .immediately
                }
            }
            context("Empty finishes by default") {
                itBehavesLike(CombinePublisher.self) {
                    Empty<Any, Never>()
                        .shouldFinish()
                        .immediately
                }
            }
            context("Fail finishes with error") {
                enum TestFailure: Error, Equatable {
                    case example
                }
                itBehavesLike(CombinePublisher.self) {
                    Fail<Any,TestFailure>(error: .example)
                        .shouldFail(expectedError: TestFailure.example)
                        .immediately
                }
            }
        }
    }
}
