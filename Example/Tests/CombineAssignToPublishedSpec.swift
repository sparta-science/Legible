import Combine
import Legible
import Nimble
import Quick

class CombineAssignToPublishedSpec: QuickSpec {
    override class func spec() {
        describe(".assign(to:)") {
            var subject: Counter!
            var publisher: PassthroughSubject<Int, Never>!
            var cancellables: Set<AnyCancellable>!
            beforeEach {
                subject = .init()
                publisher = .init()
                cancellables = .init()
            }
            it("subscribing in the middle of publisher update produce wrong value 0 instead of 2") {
                publisher
                    .assign(to: &subject.$count)

                waitUntil { done in
                    subject
                        .$count
                        .dropFirst()
                        .sink {
                            expect($0) == 2
                            expect(subject.count).to(equal(0), description: "should be 2")

                            resumeUpload(done)
                        }
                        .store(in: &cancellables)

                    publisher.send(2)
                }
                expect(subject.count).to(equal(2), description: "becomes 2 on the next runloop event")

                func resumeUpload(_ done: @escaping () -> Void) {
                    subject
                        .$count
                        .sink {
                            expect($0).to(equal(0), description: "still 0 but should be 2")
                            done()
                        }
                        .store(in: &cancellables)
                }
            }
            context(AnyPublisher<Int, Never>.assign) {
                beforeEach {
                    publisher
                        .assign(to: &subject.$count)
                }
                it(BehavesLikeCombine.self,
                   "should receive value on not main thread") {
                    subject
                        .$count
                        .dropFirst()
                        .shouldReceive(expectedValue: 1) {
                            expect(Thread.current.isMainThread) == false
                        }
                        .before(timeout: 1)
                        .when {
                            DispatchQueue.global().async {
                                publisher.send(1)
                            }
                        }
                }
            }
        }
    }
}

private class Counter: Initializable {
    @Published public var count = 0
}
