import Combine
import Nimble
import Quick
import Legible

class CombineAnySubscriberSpec: QuickSpec {
    override func spec() {
        describe("AnySubscriber.init") {
            var publisher: PassthroughSubject<String, Never>!
            weak var weakPublisher: PassthroughSubject<String, Never>!
            weak var weakSubject: PassthroughSubject<String, Never>?
            beforeEach {
                publisher = .init()
                weakPublisher = publisher
            }
            context("when publisher is not finished") {
                it(ShouldNotHaveMemoryLeaks.self, "surprisingly retains strong reference to publisher") {
                    Init(Observer()) {
                        $0.setupObserver(to: publisher.eraseToAnyPublisher())
                        weakSubject = $0.subject
                        publisher = nil
                    }
                }
                afterEach {
                    expect(weakSubject).to(beNil())
                    expect(weakPublisher).notTo(beNil(), description: "is actually not nil due to publisher strong reference")
                }
            }
            context("when publisher is finished") {
                it(ShouldNotHaveMemoryLeaks.self, "should not retain strong reference to publisher") {
                    Init(Observer()) {
                        $0.setupObserver(to: publisher.eraseToAnyPublisher())
                        weakSubject = $0.subject
                        publisher.send(completion: .finished)
                        publisher = nil
                    }
                }
                afterEach {
                    expect(weakSubject).to(beNil())
                    expect(weakPublisher).to(beNil())
                }
            }
        }
    }
}

private class Observer {
    let subject = PassthroughSubject<String, Never>()

    func setupObserver(to publisher: AnyPublisher<String, Never>) {
        publisher
            .subscribe(AnySubscriber(subject))
    }
}
