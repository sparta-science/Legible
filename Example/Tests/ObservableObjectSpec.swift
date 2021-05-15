import Nimble
import Quick
import Legible

class Weather: ObservableObject {
    @Published var temperature = 56
}

class ObservableObjectSpec: QuickSpec {
    override func spec() {
        describe("ObservableObject") {
            var subject: Weather!
            beforeEach {
                subject = .init()
            }
            context("publishes Void on change even the same") {
                itBehavesLike(CombinePublisher.self) {
                    subject.objectWillChange
                        .shouldReceive()
                        .when {
                            subject.temperature = 56
                        }
                }
            }
        }
    }
}
