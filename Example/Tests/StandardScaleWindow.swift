import AppKit

class StandardScaleWindow: NSWindow {
    override var backingScaleFactor: CGFloat {
        1
    }
}
