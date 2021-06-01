import SwiftUI

protocol Snapshotting {
    var name: String { get }
    var view: NSView { get }
    var size: NSSize? { get }
}

struct Preview<T> where T: PreviewProvider {
    let name: String
    let view: NSView
    let size: NSSize?

    init(_ type: T.Type = T.self, size: NSSize? = nil) {
        name = String(describing: T.self)
            .replacingOccurrences(of: "_Previews", with: "")
        view = NSHostingView(rootView: T.previews)
        self.size = size
    }
}

extension Preview: Snapshotting {}

struct SwiftUIView {
    let name: String
    let view: NSView
    let size: NSSize?

    init<T>(_ someView: T, name: String = String(describing: T.self), size: NSSize? = nil) where T: View {
        self.name = name
        self.size = size
        view = NSHostingView(rootView: someView)
    }
}

extension SwiftUIView: Snapshotting {}
