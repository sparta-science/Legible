import Nimble
import Quick
import Legible

func myAddFunction(_ number: Int, _ add: Int) -> Int {
    number + add
}

class BehavesLikeAsciiTableSpec: QuickSpec {
    override func spec() {
        sharedExamples("add integers") { aContext in
            it("should add") {
                let number = aContext()["number"] as! Int
                let add = aContext()["add"] as! Int
                let expected = aContext()["result"] as! Int
                expect(myAddFunction(number, add)) == expected
            }
        }
        describe("myAddFunction") {
            context("add to number to produce result") {
                itBehavesLike(AsciiTable.self) {
                    """
                    |-----------------------|
                    |      add integers     |
                    |-----------------------|
                    | number | add | result |
                    |-----------------------|
                    | 1      |  1  |   2    |
                    | -1     |  1  |   0    |
                    | 998    |  2  |  1000  |
                    |-----------------------|
                    """
                }
            }
        }
    }
}
