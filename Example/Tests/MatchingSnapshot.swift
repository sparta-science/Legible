import Quick
import Nimble
import SwiftUI

class MatchingSnapshot<Context>: Behavior<Context> where Context: View {
    override class var name: String {
        "Snapshot for \(Context.self)"
    }
    override class func spec(_ aContext: @escaping () -> Context) {
        it("should match snapshot") {
            let view = aContext()
            print(view)
        }
    }
}

