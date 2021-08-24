import Combine
import Nimble
import Quick
import Legible

class Game {
    @Published var score = "0:0"
}

class PublishedSpec: QuickSpec {
    override func spec() {
        describe("@Published") {
            var subject: Game!
            beforeEach {
                subject = .init()
            }
            context("sends current value") {
                itBehavesLike(CombinePublisher.self) {
                    subject.$score
                        .shouldReceive(expectedValue: "0:0")
                }
            }
            context("on change") {
                context("sends both") {
                    itBehavesLike(CombinePublisher.self) {
                        subject.$score
                            .collect(2)
                            .shouldReceive(expectedValue: ["0:0", "1:0"])
                            .when {
                                subject.score = "1:0"
                            }
                    }
                    itBehavesLike(CombinePublisher.self) {
                        subject.$score
                            .shouldReceive(numberOfTimes: 2)
                            .when {
                                subject.score = "5:4"
                            }
                    }
                }
                context("sends before change") {
                    itBehavesLike(CombinePublisher.self) {
                        subject.$score
                            .dropFirst()
                            .shouldReceive(expectedValue: "0:1") {
                                expect(subject.score) == "0:0"
                            }
                            .when {
                                subject.score = "0:1"
                            }
                    }
                }
            }
        }
    }
}
