import Combine
import Legible
import Nimble
import Quick

class CombineCollectOptimizationSpec: QuickSpec {
    var data: [Int]?
    func storeData(_ dataPoints: [Int]) {
        data = dataPoints
    }

    override func spec() {
        describe("optimization comparison") {
            var subject: PassthroughSubject<Int, Never>!
            var cancellables: Set<AnyCancellable>!

            beforeEach {
                subject = .init()
                cancellables = .init()
            }
            context("without .collect") {
                beforeEach {
                    subject
                        .scan([Int]()) { accumulated, current in
                            (accumulated + [current]).suffix(500)
                        }
                        .sink(receiveValue: self.storeData)
                        .store(in: &cancellables)
                }
                it("should take some time") {
                    let methodStart = Date()

                    Array(1...5000).forEach { value in
                        subject.send(value)
                    }

                    let methodFinish = Date()
                    let executionTime = methodFinish.timeIntervalSince(methodStart)
                    print("Unoptimized execution time: \(executionTime)")
                    expect(executionTime).to(beGreaterThan(0.43))
                }
            }
            context("with collect") {
                beforeEach {
                    subject
                        .collect(10)
                        .scan([Int]()) { accumulated, current in
                            (accumulated + current).suffix(500)
                        }
                        .sink(receiveValue: self.storeData)
                        .store(in: &cancellables)
                }
                it("should take some time") {
                    let methodStart = Date()

                    Array(1...5000).forEach { value in
                        subject.send(value)
                    }

                    let methodFinish = Date()
                    let executionTime = methodFinish.timeIntervalSince(methodStart)
                    print("Optimized execution time: \(executionTime)")
                    expect(executionTime).to(beLessThan(0.06))
                }
            }
        }
    }
}
