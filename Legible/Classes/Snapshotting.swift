import SwiftUI

public protocol Snapshotting {
    var name: String { get }
    var view: NSView { get }
    var size: NSSize? { get }
}

public struct Preview<T> where T: PreviewProvider {
    public let name: String
    public let view: NSView
    public let size: NSSize?

    public init(_ type: T.Type = T.self, size: NSSize? = nil) {
        name = String(describing: T.self)
            .replacingOccurrences(of: "_Previews", with: "")
        view = NSHostingView(rootView: T.previews)
        self.size = size
    }
}

extension Preview: Snapshotting {}

public struct SwiftUIView {
    public let name: String
    public let view: NSView
    public let size: NSSize?

    public init<T>(_ someView: T, name: String = String(describing: T.self), size: NSSize? = nil) where T: View {
        self.name = name
        self.size = size
        view = NSHostingView(rootView: someView)
    }
}

extension SwiftUIView: Snapshotting {}
