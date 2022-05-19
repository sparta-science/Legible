#if os(macOS)
import AppKit

public class StandardScaleWindow: NSWindow {
    var scale: Int = 2
    public init(scale: Int) {
        self.scale = scale
        super.init(
            contentRect: .init(
                origin: .zero,
                size: .init(
                    width: 1,
                    height: 1
                )
            ),
            styleMask: .borderless,
            backing: .buffered,
            defer: true
        )
    }
    override public var backingScaleFactor: CGFloat {
        .init(scale)
    }
}
#endif
