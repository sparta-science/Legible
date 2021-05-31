import Quick
import Nimble
import SwiftUI


struct Preview<T> where T: PreviewProvider {
    let name: String
    let view: some View = T.previews
    init() {
        name = String(describing: T.self)
    }
}

class MatchingSnapshot<T>: Behavior<Preview<T>> where T: PreviewProvider {
    override class var name: String {
        "Snapshot for \(T.self)"
    }
    override class func spec(_ aContext: @escaping () -> Preview<T>) {
        it("should match snapshot") {
            let view = aContext()

            print(view.name)
            print(T.previews)
        }
    }
}
