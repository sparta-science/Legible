import Combine
import Legible
import Nimble
import Quick

class CombinePublishedSpec: QuickSpec {
    override func spec() {
        describe("@Published") {
            var subject: Connection!
            beforeEach {
                subject = .init()
            }
            context("not receiving on main") {
                it(BehavesLikeCombine.self, "should not update value received in sink") {
                    subject
                        .$isOnline
                        .dropFirst()
                        .shouldReceive(expectedValue: false) {
                            expect(subject.isOnline).to(equal(true),
                                                        description: "should be true")
                        }
                        .before(timeout: 1)
                        .when {
                            subject.isOnline = false
                        }
                }
            }
            context("receiving on main with didSet") {
                it(BehavesLikeCombine.self, "update value received in sink") {
                    subject
                        .$isOnline
                        .didSet
                        .dropFirst()
                        .shouldReceive(expectedValue: false)
                        .before(timeout: 1)
                        .when {
                            subject.isOnline = false
                        }
                        .then {
                            expect(subject.isOnline) == false
                        }
                }
            }
        }
    }
}

private class Connection: Initializable {
    @Published var isOnline = true
}

extension Published.Publisher {
    var didSet: AnyPublisher<Value, Never> {
        receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
