import AppKit

class StandardScaleWindow: NSWindow {
    var scale: Int = 2
    init(scale: Int) {
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
    override var backingScaleFactor: CGFloat {
        .init(scale)
    }
}
