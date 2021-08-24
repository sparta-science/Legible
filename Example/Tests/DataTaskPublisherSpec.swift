import Combine
import Nimble
import Quick
import Legible

enum VerifiedError: Error, Equatable {
    case expected
}

private func verifyError(_ incoming: URLError) -> Error {
    expect(incoming.code) == .unsupportedURL
    expect(incoming.failingURL) == URL(string: "invalid")
    return VerifiedError.expected
}

class DataTaskPublisherSpec: QuickSpec {
    override func spec() {
        describe("dataTaskPublisher") {
            var session: URLSession!
            beforeEach {
                session = .init(configuration: .default)
            }

            context("success") {
                var url: URL!
                var expectedData: Data!
                beforeEach {
                    url = Bundle(for: Self.self)
                        .bundleURL
                        .appendingPathComponent("Contents/Info.plist")
                    expectedData = try! Data(contentsOf: url)
                }
                itBehavesLike(CombinePublisher.self) {
                    session
                        .dataTaskPublisher(for: url)
                        .map { $0.data }
                        .shouldFinish(expectedValue: expectedData)
                        .before(timeout: 10)
                }
            }

            context("failure") {
                context("sends same error on background thread") {
                    itBehavesLike(CombinePublisher.self) {
                        session
                            .dataTaskPublisher(for: URL(string: "invalid")!)
                            .mapError(verifyError)
                            .shouldFail(with: VerifiedError.expected) {
                                expect(Thread.isMainThread) == false
                            }
                            .before(timeout: 10)
                            .then {
                                expect(Thread.isMainThread) == true
                            }
                    }
                }
                context("retried sends same error") {
                    itBehavesLike(CombinePublisher.self) {
                        session
                            .dataTaskPublisher(for: URL(string: "invalid")!)
                            .retry(2)
                            .mapError(verifyError)
                            .shouldFail(with: VerifiedError.expected)
                            .before(timeout: 10)
                    }
                }
            }
        }
    }
}
