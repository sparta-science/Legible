import Quick
import Nimble
import SwiftUI


struct Preview<T> where T: PreviewProvider {
    let name: String
    let view: NSView

    init(_ type: T.Type = T.self) {
        name = String(describing: T.self)
        view = NSHostingView(rootView: T.previews)
    }
}

extension Preview: Snapshotting {}

protocol Snapshotting {
    var name: String { get }
    var view: NSView { get }
}

struct SomeView {
    let name: String
    let view: NSView

    init<T>(_ someView: T, name: String = String(describing: T.self)) where T: View {
        self.name = name
        view = NSHostingView(rootView: someView)
    }
}

extension SomeView: Snapshotting {}

class MatchingSnapshot: Behavior<Snapshotting> {
    override class var name: String {
        "Snapshot for \(Snapshotting.self)"
    }
    override class func spec(_ aContext: @escaping () -> Snapshotting) {
        it("should match snapshot") {
            let view = aContext()

            print(view.name)
            print(view.view)
        }
    }
}
