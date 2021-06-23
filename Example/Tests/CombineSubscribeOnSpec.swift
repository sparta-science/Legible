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
                        .when({
                            subject.isOnline = false
                        }, timeout: 1)
                }
            }
            context("no drop first") {
                it(BehavesLikeCombine.self, "receive false") {
                    subject
                        .$isOnline
                        .subscribe(on: DispatchQueue.main)
                        .shouldReceive(expectedValue: false)
                        .when({
                            subject.isOnline = false
                        }, timeout: 1)
                }
            }
        }
    }
}

private class Connection: Initializable {
    @Published var isOnline = true
}
