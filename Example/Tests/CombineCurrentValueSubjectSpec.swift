import Combine
import Nimble
import Quick

class CombineCurrentValueSubjectSpec: QuickSpec {
    override class func spec() {
        describe(CurrentValueSubject<Int, Never>.self) {
            var subject: CurrentValueSubject<Int, Never>!
            var cancellables: Set<AnyCancellable>!
            beforeEach {
                subject = .init(0)
                cancellables = .init()
            }
            it("should have updated value in sink") {
                waitUntil { done in
                    subject
                        .dropFirst()
                        .sink {
                            expect($0) == 1
                            expect(subject.value) == 1
                            done()
                        }
                        .store(in: &cancellables)

                    subject.send(1)
                }
            }
        }
    }
}
