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
                itBehavesLike(CombinePublisher.self) {
                    session
                        .dataTaskPublisher(for: URL(fileURLWithPath: #filePath))
                        .shouldReceive(numberOfTimes: 1)
                        .before(timeout: 10)
                }
            }

            context("failure retried sends same error") {
                itBehavesLike(CombinePublisher.self) {
                    session
                        .dataTaskPublisher(for: URL(string: "invalid")!)
                        .retry(2)
                        .mapError(verifyError)
                        .shouldFail(expectedError: VerifiedError.expected)
                        .before(timeout: 10)
                }
            }
        }
    }
}
