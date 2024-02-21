import Nimble
import Quick
import Legible

func myAddFunction(_ number: Int, _ add: Int) -> Int {
    number + add
}

class BehavesLikeAsciiTableSpec: QuickSpec {
    override class func spec() {
        sharedExamples("add integers") { aContext in
            it("should add") {
                let number = (aContext()["number"] as! String).asInt
                let add = (aContext()["add"] as! String).asInt
                let expected = (aContext()["result"] as! String).asInt
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
