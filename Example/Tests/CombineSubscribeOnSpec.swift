import Combine
import Legible
import Quick

class CombineSubscribeOnSpec: QuickSpec {
    override func spec() {
        describe(".subscribe(on:)") {
            var subject: Connection!
            beforeEach {
                subject = .init()
            }
            context("drop first") {
                it(BehavesLikeCombine.self, "should not receive anything") {
                    subject
                        .$isOnline
                        .subscribe(on: DispatchQueue.main)
                        .dropFirst()
                        .shouldNotReceive()
                        .before(timeout: 1)
                        .when {
                            subject.isOnline = false
                        }
                }
            }
            context("no drop first") {
                it(BehavesLikeCombine.self, "receive false") {
                    subject
                        .$isOnline
                        .subscribe(on: DispatchQueue.main)
                        .shouldReceive(expectedValue: false)
                        .before(timeout: 1)
                        .when {
                            subject.isOnline = false
                        }
                }
            }
        }
    }
}

private class Connection: Initializable {
    @Published var isOnline = true
}
