import SwiftUI

#if os(macOS)
public typealias View = NSView
public typealias Window = NSWindow
public typealias Image = NSImage
#elseif os(iOS)
public typealias View = UIView
public typealias Window = UIWindow
public typealias Image = UIImage
#endif

public protocol Snapshotting {
    var name: String { get }
    var view: View { get }
    var size: CGSize? { get }
}

public struct Preview<T> where T: PreviewProvider {
    public let name: String
    public let view: View
    public let size: CGSize?

    public init(_ type: T.Type = T.self, size: CGSize? = nil) {
        name = String(describing: T.self)
            .replacingOccurrences(of: "_Previews", with: "")
        #if os(macOS)
        view = NSHostingView(rootView: T.previews)
        self.size = size
        #elseif os(iOS)
        let controller = UIHostingController(rootView: T.previews.fixedSize())
        self.size = size ?? controller.sizeThatFits(in: .zero)
        self.view = controller.view
        #endif
    }
}

extension Preview: Snapshotting {}

public struct SwiftUIView {
    public let name: String
    public let view: View
    public let size: CGSize?

    public init<T>(_ someView: T, name: String = String(describing: T.self), size: CGSize? = nil) where T: SwiftUI.View {
        self.name = name
        #if os(macOS)
        self.size = size
        view = NSHostingView(rootView: someView)
        #elseif os(iOS)
        let controller = UIHostingController(rootView: someView.fixedSize())
        self.size = size ?? controller.sizeThatFits(in: .zero)
        self.view = controller.view
        #endif
    }
}

extension SwiftUIView: Snapshotting {}
