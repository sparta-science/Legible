import Combine
import Legible
import Quick

class CombineLatestSpec: QuickSpec {
    override func spec() {
        describe("Publishers.CombineLatest") {
            var subject: AnyPublisher<(String, Bool), Never>!
            context("completion when finished") {
                beforeEach {
                    subject = Publishers.CombineLatest(
                        Just("apple"),
                        Just(true)
                    )
                    .eraseToAnyPublisher()
                }
                it(BehavesLikeCombine.self, "finish and send tuple of publisher values") {
                    subject
                        .map(\.0)
                        .shouldFinish(expectedValue: "apple")
                        .immediately
                }
            }
            context("completion when not finished") {
                beforeEach {
                    subject = Publishers.CombineLatest(
                        Just("apple"),
                        Empty<Bool, Never>(completeImmediately: false)
                    )
                    .eraseToAnyPublisher()
                }
                it(BehavesLikeCombine.self, "should not finish when one of the publishers doesn't complete") {
                    subject
                        .shouldNotReceive()
                        .immediately
                }
            }
        }
    }
}
